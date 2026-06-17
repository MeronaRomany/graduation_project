import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'hf_spaces_service.dart';
import 'onnx/vits_onnx_service.dart';
import 'voice_provider.dart';

enum TTSState {
  idle,
  initializing,
  speaking,
  error,
}

class TTSService {
  final VITSOnnxService _vits;
  final HfSpacesService _hfSpaces;
  final VoiceProviderCubit _voiceProvider;
  final AudioPlayer _player = AudioPlayer();

  bool _isReady = false;
  bool _isSpeaking = false;
  
  final List<String> _sentenceQueue = [];
  bool _isProcessingQueue = false;

  final _state = StreamController<TTSState>.broadcast();
  final _error = StreamController<String>.broadcast();

  Stream<TTSState> get state => _state.stream;
  Stream<String> get error => _error.stream;

  TTSService(
    this._vits,
    this._hfSpaces,
    this._voiceProvider,
  );

  Future<void> initialize() async {
    _state.add(TTSState.initializing);

    await _vits.initVocab();

    _player.onPlayerStateChanged.listen((s) {
      if (s == PlayerState.completed) {
        _isSpeaking = false;
        if (_sentenceQueue.isNotEmpty) {
          _processQueue();
        } else {
          _isProcessingQueue = false;
          _state.add(TTSState.idle);
        }
      }
    });

    _isReady = true;
    _state.add(TTSState.idle);
  }

  Future<void> speak(String text) async {
    if (!_isReady) return;

    _sentenceQueue.clear();
    await _player.stop();
    _isSpeaking = false;

    // Split text into sentences using punctuation marks
    final RegExp sentenceSplitter = RegExp(r'(?<=[.!?])\s+');
    final sentences = text.split(sentenceSplitter).where((s) => s.trim().isNotEmpty).toList();

    if (sentences.isEmpty) {
      // If regex didn't match (no punctuation), just add the whole text
      if (text.trim().isNotEmpty) {
        _sentenceQueue.add(text.trim());
      }
    } else {
      _sentenceQueue.addAll(sentences);
    }

    if (!_isProcessingQueue && _sentenceQueue.isNotEmpty) {
      _isProcessingQueue = true;
      _state.add(TTSState.speaking);
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_sentenceQueue.isEmpty || !_isReady) {
      _isProcessingQueue = false;
      _isSpeaking = false;
      _state.add(TTSState.idle);
      return;
    }

    final String nextSentence = _sentenceQueue.removeAt(0);
    _isSpeaking = true;
    _state.add(TTSState.speaking);

    try {
      Uint8List? audioBytes;

      // Try HF Spaces TTS first when in cloud mode
      if (_voiceProvider.state.isCloud) {
        audioBytes = await _hfSpaces.generateSpeech(nextSentence);
      }

      // Fall back to local VITS ONNX if cloud failed or in local mode
      if (audioBytes == null || audioBytes.isEmpty) {
        final samples = await _vits.generateSpeech(nextSentence);
        audioBytes = _toWav(samples, 22050);
      }

      final dir = await getTemporaryDirectory();
      // Use timestamp in filename to avoid file lock issues when overriding
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/tts_output_$timestamp.wav');
      await file.writeAsBytes(audioBytes);

      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      _isSpeaking = false;
      _state.add(TTSState.error);
      _error.add(e.toString());
      
      // Continue with the next sentence if an error occurs
      if (_sentenceQueue.isNotEmpty) {
        _processQueue();
      } else {
        _isProcessingQueue = false;
        _state.add(TTSState.idle);
      }
    }
  }

  Future<void> stop() async {
    _sentenceQueue.clear();
    _isProcessingQueue = false;
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
