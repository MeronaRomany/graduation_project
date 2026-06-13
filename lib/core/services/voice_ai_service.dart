import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class VoiceAiService {
  // Use your Hugging Face API Token here
  static const String _hfToken = 'YOUR_HUGGING_FACE_TOKEN';

  // The two models the user requested
  static const String _ttsModelId = 'boules123/speecht5-finetuned-commonvoice';
  static const String _sttModelId = 'boules123/Boulesvc';

  // Singleton instance
  static final VoiceAiService _instance = VoiceAiService._internal();
  factory VoiceAiService() => _instance;
  VoiceAiService._internal();

  /// Text-to-Speech (TTS) using Hugging Face Inference API
  /// Uses: boules123/speecht5-finetuned-commonvoice
  Future<Uint8List?> generateSpeech(String text) async {
    final url = Uri.parse('https://api-inference.huggingface.co/models/$_ttsModelId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_hfToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': text}),
      );

      if (response.statusCode == 200) {
        // The API returns the raw audio bytes (usually .wav or .flac)
        return response.bodyBytes;
      } else {
        print('TTS API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during TTS API call: $e');
      return null;
    }
  }

  /// Speech-to-Text (STT) using Hugging Face Inference API
  /// Uses: boules123/Boulesvc
  Future<String?> recognizeSpeech(Uint8List audioBytes) async {
    final url = Uri.parse('https://api-inference.huggingface.co/models/$_sttModelId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_hfToken',
          'Content-Type': 'application/octet-stream',
        },
        body: audioBytes,
      );

      if (response.statusCode == 200) {
        // The API usually returns a JSON with the recognized text, e.g., {"text": "Hello world"}
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['text'] as String?;
      } else {
        print('STT API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during STT API call: $e');
      return null;
    }
  }
}

