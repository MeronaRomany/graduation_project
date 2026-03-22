import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

enum TTSState {
  idle,
  initializing,
  speaking,
  paused,
  stopped,
  error,
}

class TTSService {
  FlutterTts? _tts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  double _speechRate = 1.0;
  double _volume = 1.0;
  String _language = 'en-US';

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

      _tts = FlutterTts();

      // Test if TTS is available
      final bool isLanguageAvailable =
          await _tts!.getLanguages.then((languages) {
        return languages.contains(_language);
      }).catchError((_) => false);

      if (!isLanguageAvailable) {
        print('Warning: Language $_language may not be available');
      }

      await _tts!.setLanguage(_language);
      await _tts!.setSpeechRate(_speechRate);
      await _tts!.setVolume(_volume);

      _isInitialized = true;
      _stateController.add(TTSState.idle);

      print('TTS service initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing TTS service: $e');
      _errorController.add('Failed to initialize text-to-speech: $e');
      _stateController.add(TTSState.error);
      return false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized || _isSpeaking) {
      return;
    }

    try {
      _isSpeaking = true;
      _stateController.add(TTSState.speaking);

      print('Speaking: "$text"');

      await _tts!.speak(text);

      // Note: The text_to_speech package doesn't provide a built-in way to detect
      // when speech is complete, so we'll use a timer based on text length
      _startCompletionTimer(text);
    } catch (e) {
      print('Error during speech: $e');
      _errorController.add('Failed to speak text: $e');
      _stateController.add(TTSState.error);
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    if (!_isInitialized || !_isSpeaking) {
      return;
    }

    try {
      await _tts!.stop();
      _isSpeaking = false;
      _stateController.add(TTSState.stopped);
      print('TTS stopped');
    } catch (e) {
      print('Error stopping TTS: $e');
      _errorController.add('Failed to stop speech: $e');
    }
  }

  Future<void> pause() async {
    if (!_isInitialized || !_isSpeaking) {
      return;
    }

    try {
      await _tts!.pause();
      _stateController.add(TTSState.paused);
      print('TTS paused');
    } catch (e) {
      print('Error pausing TTS: $e');
      _errorController.add('Failed to pause speech: $e');
    }
  }

  Future<void> resume() async {
    if (!_isInitialized) {
      return;
    }

    try {
       _tts!.continueHandler;
      _stateController.add(TTSState.speaking);
      print('TTS resumed');
    } catch (e) {
      print('Error resuming TTS: $e');
      _errorController.add('Failed to resume speech: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;

    try {
      _speechRate = rate.clamp(0.1, 2.0);
      await _tts!.setSpeechRate(_speechRate);
      print('Speech rate set to: $_speechRate');
    } catch (e) {
      print('Error setting speech rate: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      _volume = volume.clamp(0.0, 1.0);
      await _tts!.setVolume(_volume);
      print('Volume set to: $_volume');
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    if (!_isInitialized) return;

    try {
      _language = language;
      await _tts!.setLanguage(_language);
      print('Language set to: $_language');
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) return [];

    try {
      return await _tts!.getLanguages;
    } catch (e) {
      print('Error getting languages: $e');
      return [];
    }
  }

  Future<List<String>> getAvailableVoices() async {
    if (!_isInitialized) return [];

    try {
      // The text_to_speech package doesn't have getVoices method
      // Return empty list as voices are not supported in this version
      return [];
    } catch (e) {
      print('Error getting voices: $e');
      return [];
    }
  }

  void _startCompletionTimer(String text) {
    // Estimate speech duration based on text length
    // Average speaking rate is about 150 words per minute, or roughly 2.5 words per second
    final wordCount = text.split(' ').length;
    final estimatedDurationSeconds = (wordCount / 2.5).ceil();

    // Add some buffer time and set a maximum duration
    final duration =
        Duration(seconds: (estimatedDurationSeconds + 2).clamp(3, 30));

    Timer(duration, () {
      if (_isSpeaking) {
        _isSpeaking = false;
        _stateController.add(TTSState.idle);
        print('TTS completed (timer-based)');
      }
    });
  }

  // Method to check if speech is currently playing
  // This is a workaround since the TTS package doesn't provide completion callbacks
  bool get isCurrentlySpeaking {
    return _isSpeaking;
  }

  void dispose() {
    _tts?.stop();
    _stateController.close();
    _errorController.close();
  }
}
