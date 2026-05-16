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
  stopped,
  error,
}

class TTSService {
  final AudioPlayer _player = AudioPlayer();
  final VITSOnnxService _vits = VITSOnnxService();

  bool _isInitialized = false;
  bool _isSpeaking = false;

  final StreamController<TTSState> _state =
  StreamController<TTSState>.broadcast();

  final StreamController<String> _error =
  StreamController<String>.broadcast();

  Stream<TTSState> get state => _state.stream;

  /// اسمه `error` مش `errors` عشان يتوافق مع ConversationBloc
  Stream<String> get error => _error.stream;

  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;

  // ---------------- INIT ----------------

  /// بترجع Future<bool> عشان ConversationBloc يقدر يتحقق منها
  Future<bool> initialize() async {
    try {
      _state.add(TTSState.initializing);

      await _vits.init();

      _isInitialized = true;
      _state.add(TTSState.idle);

      _player.onPlayerStateChanged.listen((s) {
        if (s == PlayerState.completed) {
          _isSpeaking = false;
          _state.add(TTSState.idle);
        }
      });

      return true;
    } catch (e) {
      _error.add("Init failed: $e");
      _state.add(TTSState.error);
      return false;
    }
  }

  // ---------------- SPEAK ----------------
  Future<void> speak(String text) async {
    if (!_isInitialized || _isSpeaking || text.trim().isEmpty) return;

    try {
      _isSpeaking = true;
      _state.add(TTSState.speaking);

      final Float32List audio = await _vits.generateSpeech(text);
      final wav = _floatToWav16Bit(audio, sampleRate: 22050);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tts.wav');
      await file.writeAsBytes(wav, flush: true);

      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      _isSpeaking = false;
      _state.add(TTSState.error);
      _error.add("Speak failed: $e");
    }
  }

  // ---------------- STOP ----------------
  Future<void> stop() async {
    await _player.stop();
    _isSpeaking = false;
    _state.add(TTSState.idle); // idle مش stopped عشان BLoC يعرف إنه خلص
  }

  // ---------------- WAV (PCM16) ----------------
  Uint8List _floatToWav16Bit(Float32List samples, {required int sampleRate}) {
    final int byteRate = sampleRate * 2;
    final int dataSize = samples.length * 2;
    final int fileSize = 36 + dataSize;

    final header = ByteData(44);

    // RIFF
    header.setUint8(0, 0x52);
    header.setUint8(1, 0x49);
    header.setUint8(2, 0x46);
    header.setUint8(3, 0x46);
    header.setUint32(4, fileSize, Endian.little);
    // WAVE
    header.setUint8(8, 0x57);
    header.setUint8(9, 0x41);
    header.setUint8(10, 0x56);
    header.setUint8(11, 0x45);
    // fmt
    header.setUint8(12, 0x66);
    header.setUint8(13, 0x6d);
    header.setUint8(14, 0x74);
    header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // mono
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    // data
    header.setUint8(36, 0x64);
    header.setUint8(37, 0x61);
    header.setUint8(38, 0x74);
    header.setUint8(39, 0x61);
    header.setUint32(40, dataSize, Endian.little);

    final bytes = Uint8List(44 + dataSize);
    bytes.setAll(0, header.buffer.asUint8List());

    final bd = ByteData.view(bytes.buffer);
    int offset = 44;
    for (int i = 0; i < samples.length; i++) {
      double v = samples[i].clamp(-1.0, 1.0);
      bd.setInt16(offset, (v * 32767).toInt(), Endian.little);
      offset += 2;
    }

    return bytes;
  }


  // ---------------- DISPOSE ----------------
  void dispose() {
    _player.dispose();
    _vits.dispose();
    _state.close();
    _error.close();
  }
}
