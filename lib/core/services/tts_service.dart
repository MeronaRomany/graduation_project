import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'hf_spaces_service.dart';

enum TTSState {
  idle,
  initializing,
  speaking,
  error,
}

class TTSService {
  final HfSpacesService _hfSpaces;
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
    this._hfSpaces,
  );

  Future<void> initialize() async {
    _state.add(TTSState.initializing);

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
      Uint8List? audioBytes = await _hfSpaces.generateSpeech(nextSentence);

      if (audioBytes == null || audioBytes.isEmpty) {
        throw Exception("Failed to generate speech from cloud.");
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
}
