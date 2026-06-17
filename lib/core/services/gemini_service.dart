import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_instructions.dart';
import '../config/api_config.dart';
import '../role_play_prompts.dart';
import '../../features/home/data/models/role_play_scenario.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  final http.Client _client;

  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> generateResponse({
    required String userMessage,
    required String conversationHistory,
    RolePlayScenario? scenario,
    required String userLevel,
    String? currentTopic,
  }) async {
    try {
      String prompt = _buildPrompt(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        userLevel: userLevel,
        currentTopic: currentTopic,
        scenario: scenario,
      );

      final response = await _client.post(
        Uri.parse('$_baseUrl?key=${APIConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].trim();
      } else {
        throw Exception('API error ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackResponse(userMessage);
    }
  }

  String _buildPrompt({
    required String userMessage,
    required String conversationHistory,
    required String userLevel,
    String? currentTopic,
    RolePlayScenario? scenario,
  }) {
    if (scenario != null) {
      return RolePlayPrompts.buildScenarioPrompt(
        scenario: scenario,
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        userLevel: userLevel,
      );
    }
    return "Help user practice English. History: $conversationHistory. User: $userMessage";
  }

  String _getFallbackResponse(String userMessage) {
    return "I'm having some trouble connecting. Let's try again.";
  }

  Future<Map<String, dynamic>> evaluateSession({
    required String conversationHistory,
    required String type, 
  }) async {
    final prompt = '''
Evaluate this English ${type == 'writing' ? 'writing' : 'conversation'}.
History:
$conversationHistory
Provide JSON: grammar_score, vocabulary_score, fluency_score, overall_score, mistakes_score, feedback.
''';

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl?key=${APIConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {'temperature': 0.1}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(text);
      }
      throw Exception('Evaluation failed');
    } catch (e) {
      return {'grammar_score': 0, 'vocabulary_score': 0, 'fluency_score': 0, 'overall_score': 0, 'mistakes_score': 0, 'feedback': 'Error'};
    }
  }

  Future<String> analyzeWriting({
    required String text,
    required String scenarioTitle,
    required String userLevel,
  }) async {
    final prompt = '''
Analyze the following English writing. 
Scenario: $scenarioTitle
User Level: $userLevel
Text: "$text"

Respond ONLY with a JSON object containing:
"correctedText", "overallScore", "grammarScore", "vocabularyScore", "fluencyScore", "improvementSuggestions" (list), "mistakes" (list of objects with wrong, correct, reason).
''';

    final response = await _client.post(
      Uri.parse('$_baseUrl?key=${APIConfig.geminiApiKey}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{'parts': [{'text': prompt}]}],
        'generationConfig': {'temperature': 0.1}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String result = data['candidates'][0]['content']['parts'][0]['text'];
      return result.replaceAll('```json', '').replaceAll('```', '').trim();
    } else {
      throw Exception('Writing analysis failed: ${response.statusCode}');
    }
  }

  void dispose() => _client.close();
}
