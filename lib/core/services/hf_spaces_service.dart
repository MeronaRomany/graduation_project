import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Hugging Face Spaces API Service
///
/// Provides TTS and STT via the custom FastAPI Space:
/// https://boules123-grad-voice-ai.hf.space/
///
/// Endpoints:
/// - POST /tts  -> JSON {"text": "..."} -> WAV audio bytes
/// - POST /stt  -> multipart/form-data {"file": <audio>} -> JSON {"text": "..."}
class HfSpacesService {
  static const String _baseUrl = 'https://boules123-grad-voice-ai.hf.space';
  static const Duration _timeout = Duration(seconds: 30);

  static final HfSpacesService _instance = HfSpacesService._internal();
  factory HfSpacesService() => _instance;
  HfSpacesService._internal();

  /// Convert text to speech via HF Spaces TTS endpoint.
  /// Returns WAV audio bytes, or null on failure.
  Future<Uint8List?> generateSpeech(String text) async {
    final url = Uri.parse('$_baseUrl/tts');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }

      print('HF Spaces TTS error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('HF Spaces TTS exception: $e');
      return null;
    }
  }

  /// Convert speech to text via HF Spaces STT endpoint.
  /// Accepts raw audio bytes (WAV), returns transcribed text or null.
  Future<String?> recognizeSpeech(Uint8List audioBytes) async {
    final url = Uri.parse('$_baseUrl/stt');

    try {
      final request = http.MultipartRequest('POST', url)
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: 'audio.wav',
        ));

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['text'] as String?;
      }

      print('HF Spaces STT error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('HF Spaces STT exception: $e');
      return null;
    }
  }

  /// Save audio bytes to a temporary WAV file and return the path.
  Future<String> saveTempWav(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/hf_spaces_audio.wav');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Quick health check — returns true if the Space is reachable.
  Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
