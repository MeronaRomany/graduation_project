import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'onnx/vits_onnx_service.dart';

enum TTSState {
  idle,
  initializing,
  speaking,
  paused,
  stopped,
  error,
}

class TTSService {
  final AudioPlayer _player = AudioPlayer();
  final VITSOnnxService _vitsOnnxService = VITSOnnxService();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  final StreamController<TTSState> _stateController =
      StreamController<TTSState>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  Stream<TTSState> get state => _stateController.stream;
  Stream<String> get error => _errorController.stream;

  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;

  Future<bool> initialize() async {
    try {
      _stateController.add(TTSState.initializing);
      await _vitsOnnxService.init();
      _isInitialized = true;
      _stateController.add(TTSState.idle);
      
      _player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          _isSpeaking = false;
          _stateController.add(TTSState.idle);
        }
      });
      
      return true;
    } catch (e) {
      _errorController.add('TTS Init failed: $e');
      return false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized || _isSpeaking) return;

    try {
      _isSpeaking = true;
      _stateController.add(TTSState.speaking);

      final samples = await _vitsOnnxService.generateSpeech(text);
      final wavBytes = _createWavHeader(samples);
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/tts_output.wav');
      await file.writeAsBytes(wavBytes);
      
      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      _errorController.add('Speak failed: $e');
      _isSpeaking = false;
      _stateController.add(TTSState.error);
    }
  }

  Uint8List _createWavHeader(Float32List samples) {
    // Simple WAV header for mono 22050Hz float PCM (VITS default)
    // Actually VITS might be 16kHz or 22kHz, adjusting to 22050 for now
    const int sampleRate = 22050;
    final int byteRate = sampleRate * 4;
    final int dataSize = samples.length * 4;
    final int fileSize = 36 + dataSize;

    final header = ByteData(44);
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    
    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6d); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); //  
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 3, Endian.little); // IEEE Float
    header.setUint16(22, 1, Endian.little); // Mono
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, 4, Endian.little);
    header.setUint16(34, 32, Endian.little);
    
    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    final wav = Uint8List(44 + dataSize);
    wav.setAll(0, header.buffer.asUint8List());
    wav.setAll(44, samples.buffer.asUint8List());
    return wav;
  }

  Future<void> stop() async {
    await _player.stop();
    _isSpeaking = false;
    _stateController.add(TTSState.stopped);
  }

  void dispose() {
    _player.dispose();
    _vitsOnnxService.dispose();
    _stateController.close();
    _errorController.close();
  }
}
