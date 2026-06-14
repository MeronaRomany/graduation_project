import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Voice AI Service for Hugging Face API
/// 
/// This service provides TTS and STT functionality using Hugging Face models.
/// 
/// IMPORTANT: The custom models (boules123/*) are NOT supported by the
/// serverless Inference API. They need to be deployed as Inference Endpoints.
/// 
/// For production use, consider:
/// 1. Deploying models as Inference Endpoints
/// 2. Using standard models from the Hub
/// 3. Using local ONNX models (already implemented in the app)
class VoiceAiService {
  // Use your Hugging Face API Token here
  static const String _hfToken = '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';

  // The two models the user requested
  static const String _ttsModelId = 'boules123/speecht5-finetuned-commonvoice';
  static const String _sttModelId = 'boules123/Boulesvc';

  // Fallback standard models (supported by Inference API)
  static const String _ttsFallbackModel = 'hexgrad/Kokoro-82M';
  static const String _sttFallbackModel = 'openai/whisper-large-v3';

  // API endpoints
  static const String _apiBase = 'https://router.huggingface.co/hf-inference/models';

  // Singleton instance
  static final VoiceAiService _instance = VoiceAiService._internal();
  factory VoiceAiService() => _instance;
  VoiceAiService._internal();

  /// Text-to-Speech (TTS) using Hugging Face Inference API
  /// 
  /// First tries the custom model, then falls back to standard model.
  /// Returns null if both fail.
  Future<Uint8List?> generateSpeech(String text) async {
    // Try custom model first
    var result = await _callTtsApi(_ttsModelId, text);
    if (result != null) return result;

    // Fall back to standard model
    print('Custom TTS model failed, trying fallback...');
    result = await _callTtsApi(_ttsFallbackModel, text);
    return result;
  }

  /// Call TTS API with specific model
  Future<Uint8List?> _callTtsApi(String modelId, String text) async {
    final url = Uri.parse('$_apiBase/$modelId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_hfToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': text}),
      ).timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 503) {
        print('TTS Model $modelId is loading (cold start)');
        return null;
      } else {
        print('TTS API Error ($modelId): ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during TTS API call ($modelId): $e');
      return null;
    }
  }

  /// Speech-to-Text (STT) using Hugging Face Inference API
  /// 
  /// First tries the custom model, then falls back to standard model.
  /// Returns null if both fail.
  Future<String?> recognizeSpeech(Uint8List audioBytes) async {
    // Try custom model first
    var result = await _callSttApi(_sttModelId, audioBytes);
    if (result != null) return result;

    // Fall back to standard model
    print('Custom STT model failed, trying fallback...');
    result = await _callSttApi(_sttFallbackModel, audioBytes);
    return result;
  }

  /// Call STT API with specific model
  Future<String?> _callSttApi(String modelId, Uint8List audioBytes) async {
    final url = Uri.parse('$_apiBase/$modelId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_hfToken',
          'Content-Type': 'audio/wav',
        },
        body: audioBytes,
      ).timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['text'] as String?;
      } else if (response.statusCode == 503) {
        print('STT Model $modelId is loading (cold start)');
        return null;
      } else {
        print('STT API Error ($modelId): ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during STT API call ($modelId): $e');
      return null;
    }
  }

  /// Test the API connection and models
  Future<Map<String, dynamic>> testApi() async {
    final Map<String, dynamic> results = {
      'tokenValid': false,
      'ttsModelAccessible': false,
      'sttModelAccessible': false,
      'ttsApiWorking': false,
      'sttApiWorking': false,
      'errors': <String>[],
    };

    // Test token
    try {
      final response = await http.get(
        Uri.parse('https://huggingface.co/api/whoami-v2'),
        headers: {'Authorization': 'Bearer $_hfToken'},
      );
      results['tokenValid'] = response.statusCode == 200;
      if (response.statusCode != 200) {
        results['errors'].add('Token validation failed: ${response.statusCode}');
      }
    } catch (e) {
      results['errors'].add('Token test error: $e');
    }

    // Test model access
    try {
      final ttsResponse = await http.get(
        Uri.parse('https://huggingface.co/api/models/$_ttsModelId'),
        headers: {'Authorization': 'Bearer $_hfToken'},
      );
      results['ttsModelAccessible'] = ttsResponse.statusCode == 200;
    } catch (e) {
      results['errors'].add('TTS model access error: $e');
    }

    try {
      final sttResponse = await http.get(
        Uri.parse('https://huggingface.co/api/models/$_sttModelId'),
        headers: {'Authorization': 'Bearer $_hfToken'},
      );
      results['sttModelAccessible'] = sttResponse.statusCode == 200;
    } catch (e) {
      results['errors'].add('STT model access error: $e');
    }

    return results;
  }
}
