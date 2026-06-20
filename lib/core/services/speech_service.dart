import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'hf_spaces_service.dart';

enum SpeechState {
  idle,
  listening,
  completed,
}

class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  final HfSpacesService _hfSpaces;

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
    this._hfSpaces,
  );

  Future<bool> initialize() async {
    try {
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
      String? text = await _hfSpaces.recognizeSpeech(bytes);

      if (text != null && text.trim().isNotEmpty) {
        _result.add(text);
      }

      _state.add(SpeechState.completed);
    } catch (e) {
      _isListening = false;
      _error.add(e.toString());
    }
  }

  Future<void> dispose() async {
    _result.close();
    _error.close();
    _state.close();
    await _recorder.dispose();
  }
}
