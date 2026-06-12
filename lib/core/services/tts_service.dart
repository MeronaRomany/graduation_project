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
  error,
}

class TTSService {
  final VITSOnnxService _vits;
  final AudioPlayer _player = AudioPlayer();

  bool _isReady = false;
  bool _isSpeaking = false;

  final _state = StreamController<TTSState>.broadcast();
  final _error = StreamController<String>.broadcast();

  Stream<TTSState> get state => _state.stream;
  Stream<String> get error => _error.stream;

  TTSService(this._vits);

  Future<void> initialize() async {
    _state.add(TTSState.initializing);

    await _vits.initVocab();

    _player.onPlayerStateChanged.listen((s) {
      if (s == PlayerState.completed) {
        _isSpeaking = false;
        _state.add(TTSState.idle);
      }
    });

    _isReady = true;
    _state.add(TTSState.idle);
  }

  Future<void> speak(String text) async {
    if (!_isReady || _isSpeaking) return;

    try {
      _isSpeaking = true;
      _state.add(TTSState.speaking);

      final audio = await _vits.generateSpeech(text);
      final wav = _toWav(audio, 22050);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tts.wav');

      await file.writeAsBytes(wav);

      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      _isSpeaking = false;
      _state.add(TTSState.error);
      _error.add(e.toString());
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isSpeaking = false;
    _state.add(TTSState.idle);
  }

  Future<void> dispose() async {
     _player.dispose();
    await _state.close();
    await _error.close();
  }

  Uint8List _toWav(Float32List samples, int sampleRate) {
    final byteRate = sampleRate * 2;
    final size = samples.length * 2;

    final header = ByteData(44);

    header.setUint8(0, 0x52);
    header.setUint8(1, 0x49);
    header.setUint8(2, 0x46);
    header.setUint8(3, 0x46);

    header.setUint32(4, 36 + size, Endian.little);

    header.setUint8(8, 0x57);
    header.setUint8(9, 0x41);
    header.setUint8(10, 0x56);
    header.setUint8(11, 0x45);

    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);

    final bytes = Uint8List(44 + size);
    bytes.setAll(0, header.buffer.asUint8List());

    final bd = ByteData.view(bytes.buffer);

    int offset = 44;

    for (final s in samples) {
      bd.setInt16(
        offset,
        (s.clamp(-1.0, 1.0) * 32767).toInt(),
        Endian.little,
      );
      offset += 2;
    }

    return bytes;
  }
}