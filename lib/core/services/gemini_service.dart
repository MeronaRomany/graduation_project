import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_instructions.dart';
import '../config/api_config.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  // API key is loaded from config file

  final http.Client _client;

  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> generateResponse({
    required String userMessage,
    required String conversationHistory,
    required String userLevel,
    String? currentTopic,
  }) async {
    try {
      final prompt = _buildPrompt(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        userLevel: userLevel,
        currentTopic: currentTopic,
      );

      final response = await _client.post(
        Uri.parse('$_baseUrl?key=${APIConfig.geminiApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception('Failed to generate response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating Gemini response: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  String _buildPrompt({
    required String userMessage,
    required String conversationHistory,
    required String userLevel,
    String? currentTopic,
  }) {
    final String topic = currentTopic ?? 'general conversation';
    final String goals =
        'Help user practice English through natural conversation';

    final personalizedPrompt = AIInstructions.getPersonalizedPrompt(
      userLevel: userLevel,
      currentTopic: topic,
      sessionGoals: goals,
      conversationHistory: conversationHistory,
    );

    return '''
$personalizedPrompt

USER MESSAGE: "$userMessage"

Please respond as an English language tutor. Keep your response conversational, educational, and engaging. If the user made any errors, correct them gently and explain why. Ask follow-up questions to continue the conversation.

Remember to:
- Be encouraging and supportive
- Adapt to the user's level
- Focus on natural English usage
- Provide learning opportunities
- Keep responses appropriate in length for a conversation

AI RESPONSE:''';
  }

  String _getFallbackResponse(String userMessage) {
    // Fallback responses for when the API fails
    final fallbackResponses = [
      "I'm sorry, I'm having trouble connecting right now. Could you try saying that again?",
      "I didn't quite catch that. Could you repeat it for me?",
      "There seems to be a technical issue. Let's continue our conversation - what would you like to talk about?",
      "I'm experiencing some connectivity issues. Could you rephrase that for me?",
    ];

    // Simple keyword-based responses for common scenarios
    final message = userMessage.toLowerCase();

    if (message.contains('hello') || message.contains('hi')) {
      return "Hello! Great to see you. How are you doing today?";
    } else if (message.contains('help') || message.contains('practice')) {
      return "I'd love to help you practice English! What would you like to talk about today?";
    } else if (message.contains('thank')) {
      return "You're very welcome! I'm glad I could help. What else would you like to practice?";
    } else if (message.contains('bye') || message.contains('goodbye')) {
      return "Goodbye! It was great practicing with you. Come back anytime!";
    }

    return fallbackResponses[
        DateTime.now().millisecond % fallbackResponses.length];
  }

  Future<String> assessUserLevel(String sampleText) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl?key=${APIConfig.geminiApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''
Analyze this English text sample and determine the user's proficiency level. Consider vocabulary, grammar, sentence structure, and overall fluency.

Text: "$sampleText"

Respond with ONLY one of these levels: beginner, elementary, intermediate, advanced

Choose the most appropriate level based on:
- Vocabulary range and complexity
- Grammar accuracy and variety
- Sentence structure sophistication
- Overall fluency indicators

Level:'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 50,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final level = data['candidates'][0]['content']['parts'][0]['text']
            .trim()
            .toLowerCase();

        // Ensure we return a valid level
        if (['beginner', 'elementary', 'intermediate', 'advanced']
            .contains(level)) {
          return level;
        }
      }

      return 'intermediate'; // Default fallback level
    } catch (e) {
      print('Error assessing user level: $e');
      return 'intermediate'; // Default fallback level
    }
  }

  void dispose() {
    _client.close();
  }
}
