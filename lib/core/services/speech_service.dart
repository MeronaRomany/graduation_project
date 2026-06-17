import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'hf_spaces_service.dart';
import 'onnx/whisper_onnx_service.dart';
import 'voice_provider.dart';

enum SpeechState {
  idle,
  listening,
  completed,
}

class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  final WhisperOnnxService _whisper;
  final HfSpacesService _hfSpaces;
  final VoiceProviderCubit _voiceProvider;

  bool _isListening = false;
  bool _isInit = false;

  final StreamController<String> _result = StreamController.broadcast();
  final StreamController<String> _error = StreamController.broadcast();
  final StreamController<SpeechState> _state = StreamController.broadcast();

  Stream<String> get result => _result.stream;
  Stream<String> get error => _error.stream;
  Stream<SpeechState> get state => _state.stream;

  bool get isListening => _isListening;

  SpeechService(
    this._whisper,
    this._hfSpaces,
    this._voiceProvider,
  );

  Future<bool> initialize() async {
    try {
      await _whisper.init();
      _isInit = true;
      _state.add(SpeechState.idle);
      return true;
    } catch (e) {
      _error.add(e.toString());
      return false;
    }
  }

  Future<void> startListening() async {
    if (!_isInit || _isListening) return;

    try {
      final dir = await getTemporaryDirectory();
      final path = "${dir.path}/audio.wav";

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );

      _isListening = true;
      _state.add(SpeechState.listening);
    } catch (e) {
      _error.add(e.toString());
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      final path = await _recorder.stop();
      _isListening = false;

      if (path == null) return;

      final bytes = await File(path).readAsBytes();
      String? text;

      // Try HF Spaces STT first when in cloud mode
      if (_voiceProvider.state.isCloud) {
        text = await _hfSpaces.recognizeSpeech(bytes);
      }

      // Fall back to local Whisper ONNX if cloud failed or in local mode
      if (text == null || text.trim().isEmpty) {
        final audio = _wavToFloat32(bytes);
        if (audio.isNotEmpty) {
          text = await _whisper.transcribe(audio);
        }
      }

      if (text != null && text.trim().isNotEmpty) {
        _result.add(text);
      }

      _state.add(SpeechState.completed);
    } catch (e) {
      _isListening = false;
      _error.add(e.toString());
    }
  }

  Float32List _wavToFloat32(Uint8List bytes) {
    if (bytes.length <= 44) return Float32List(0);

    final pcm = bytes.sublist(44);
    final int16 = pcm.buffer.asInt16List();

    return Float32List.fromList(
      int16.map((e) => e / 32768.0).toList(),
    );
  }

  Future<void> dispose() async {
    _result.close();
    _error.close();
    _state.close();
    await _recorder.dispose();
  }
}
