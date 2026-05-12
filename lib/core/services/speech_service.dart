import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

enum SpeechState {
  idle,
  initializing,
  listening,
  processing,
  completed,
  error,
}

class SpeechService {
  static const Duration _silenceTimeout = Duration(seconds: 3);
  static const Duration _maxRecordingDuration = Duration(minutes: 2);

  WhisperController? _whisperController;
  Timer? _silenceTimer;
  Timer? _maxDurationTimer;
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

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  Future<bool> initialize() async {
    try {
      _stateController.add(SpeechState.initializing);

      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        _errorController
            .add('Microphone permission is required for speech recognition');
        _stateController.add(SpeechState.error);
        return false;
      }

      // Initialize Whisper
      _whisperController = WhisperController();
      await _whisperController!.initModel(
          WhisperModel.tiny); // Using tiny model for better performance

      _isInitialized = true;
      _stateController.add(SpeechState.idle);

      print('Speech service initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing speech service: $e');
      _errorController.add('Failed to initialize speech recognition: $e');
      _stateController.add(SpeechState.error);
      return false;
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized || _isListening) {
      return;
    }

    try {
      _isListening = true;
      _stateController.add(SpeechState.listening);

      // Create temporary file for audio
      final tempDir = await getTemporaryDirectory();
      final audioPath =
          '${tempDir.path}/speech_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start recording (using flutter_sound for better control)
      await _startRecording(audioPath);

      // Start silence detection
      _startSilenceDetection();

      // Start max duration timer
      _maxDurationTimer = Timer(_maxRecordingDuration, () {
        stopListening();
      });

      print('Started listening for speech');
    } catch (e) {
      print('Error starting speech recognition: $e');
      _errorController.add('Failed to start listening: $e');
      _stateController.add(SpeechState.error);
      _isListening = false;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      _isListening = false;

      // Cancel timers
      _silenceTimer?.cancel();
      _maxDurationTimer?.cancel();

      _stateController.add(SpeechState.processing);

      // Stop recording and get the audio file
      final audioPath = await _stopRecording();

      if (audioPath != null && await File(audioPath).exists()) {
        // Process the audio file with Whisper
        await _processAudioFile(audioPath);
      } else {
        _errorController.add('No audio recorded');
        _stateController.add(SpeechState.error);
      }
    } catch (e) {
      print('Error stopping speech recognition: $e');
      _errorController.add('Failed to stop listening: $e');
      _stateController.add(SpeechState.error);
    }
  }

  Future<void> _processAudioFile(String audioPath) async {
    try {
      print('Processing audio file: $audioPath');

      final result = await _whisperController?.transcribe(
        model: WhisperModel.tiny,
        audioPath: audioPath,
        lang: 'en', // English language
      );

      // Clean up audio file
      try {
        await File(audioPath).delete();
      } catch (e) {
        print('Warning: Could not delete temporary audio file: $e');
      }

      final transcription = result?.transcription;
      final text = transcription?.text;

      if (text != null && text.isNotEmpty) {
        final trimmedText = text.trim();
        print('Speech recognition result: "$trimmedText"');

        // Filter out very short or nonsensical results
        if (trimmedText.length > 2 && !_isNoise(trimmedText)) {
          _resultController.add(trimmedText);
          _stateController.add(SpeechState.completed);
        } else {
          _errorController.add('Speech not clear enough to recognize');
          _stateController.add(SpeechState.error);
        }
      } else {
        _errorController.add('No speech detected');
        _stateController.add(SpeechState.error);
      }
    } catch (e) {
      print('Error processing audio: $e');
      _errorController.add('Failed to process speech: $e');
      _stateController.add(SpeechState.error);
    }
  }

  void _startSilenceDetection() {
    // For now, we'll use a simple timeout-based approach
    // In a real implementation, you might want to use audio level detection
    _silenceTimer = Timer(_silenceTimeout, () {
      if (_isListening) {
        print('Silence detected, stopping listening');
        stopListening();
      }
    });
  }

  bool _isNoise(String text) {
    // Filter out common noise patterns
    final noisePatterns = [
      'thank you',
      'thanks for watching',
      'you',
      'the',
      'a',
      'an',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'could',
      'should',
      'may',
      'might',
      'must',
      'can',
    ];

    final lowerText = text.toLowerCase().trim();
    return noisePatterns.contains(lowerText) || lowerText.length < 3;
  }

  // Placeholder methods for audio recording - you might want to use flutter_sound
  Future<void> _startRecording(String path) async {
    // Implementation would use flutter_sound or similar for recording
    // For now, this is a placeholder
    print('Starting recording to: $path');
  }

  Future<String?> _stopRecording() async {
    // Implementation would stop flutter_sound recording and return the file path
    // For now, this is a placeholder
    print('Stopping recording');
    return null;
  }

  void dispose() {
    _silenceTimer?.cancel();
    _maxDurationTimer?.cancel();
    _stateController.close();
    _resultController.close();
    _errorController.close();
  }
}
