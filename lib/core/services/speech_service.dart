import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'onnx/whisper_onnx_service.dart';

enum SpeechState {
  idle,
  initializing,
  listening,
  processing,
  completed,
  error,
}

class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  final WhisperOnnxService _whisperOnnxService = WhisperOnnxService();
  
  bool _isListening = false;
  bool _isInitialized = false;

  final StreamController<SpeechState> _stateController =
      StreamController<SpeechState>.broadcast();
  final StreamController<String> _resultController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  Stream<SpeechState> get state => _stateController.stream;
  Stream<String> get result => _resultController.stream;
  Stream<String> get error => _errorController.stream;

  Future<bool> initialize() async {
    try {
      _stateController.add(SpeechState.initializing);
      
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        _errorController.add('Microphone permission required');
        return false;
      }

      await _whisperOnnxService.init();
      _isInitialized = true;
      _stateController.add(SpeechState.idle);
      return true;
    } catch (e) {
      _errorController.add('Init failed: $e');
      return false;
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized || _isListening) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/audio.wav';
      
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );

      await _recorder.start(config, path: path);
      _isListening = true;
      _stateController.add(SpeechState.listening);
    } catch (e) {
      _errorController.add('Start failed: $e');
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      final path = await _recorder.stop();
      _isListening = false;
      _stateController.add(SpeechState.processing);

      if (path != null) {
        final bytes = await File(path).readAsBytes();
        // Convert WAV bytes to Float32List (skipping header)
        final samples = _processWavBytes(bytes);
        final text = await _whisperOnnxService.transcribe(samples);
        _resultController.add(text);
        _stateController.add(SpeechState.completed);
      }
    } catch (e) {
      _errorController.add('Stop failed: $e');
    }
  }

  Float32List _processWavBytes(Uint8List bytes) {
    // Very basic WAV to PCM float conversion (skipping 44 bytes header)
    final pcmData = bytes.sublist(44);
    final int16List = pcmData.buffer.asInt16List();
    final float32List = Float32List(int16List.length);
    for (var i = 0; i < int16List.length; i++) {
      float32List[i] = int16List[i] / 32768.0;
    }
    return float32List;
  }

  void dispose() {
    _recorder.dispose();
    _whisperOnnxService.dispose();
    _stateController.close();
    _resultController.close();
    _errorController.close();
  }
}
