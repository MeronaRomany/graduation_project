import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_instructions.dart';
import '../config/api_config.dart';
import '../role_play_prompts.dart';
import '../../features/home/data/models/role_play_scenario.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';
  // API key is loaded from config file

  final http.Client _client;

  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> generateResponse({
    required String userMessage,
    required String conversationHistory,
    RolePlayScenario? scenario,
    required String userLevel,
    String? currentTopic,
  }) async {
    print('[GeminiService] Generating response...');
    print('[GeminiService] User message: "${userMessage.substring(0, userMessage.length > 30 ? 30 : userMessage.length)}..."');
    print('[GeminiService] User level: $userLevel');
    print('[GeminiService] Scenario: ${scenario?.title ?? "None"}');
    
    try {
      // Build prompt with error handling
      String prompt;
      try {
        prompt = _buildPrompt(
          userMessage: userMessage,
          conversationHistory: conversationHistory,
          userLevel: userLevel,
          currentTopic: currentTopic,
          scenario: scenario,
        );
        print('[GeminiService] Prompt built successfully');
      } catch (e, stackTrace) {
        print('[GeminiService ERROR] Failed to build prompt: $e');
        print('[GeminiService ERROR] Stack trace: $stackTrace');
        throw Exception('Failed to build prompt: $e');
      }

      // Make API request with detailed error handling
      http.Response response;
      try {
        print('[GeminiService] Making API request...');
        response = await _client.post(
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
        print('[GeminiService] API response received: ${response.statusCode}');
      } catch (e, stackTrace) {
        print('[GeminiService ERROR] API request failed: $e');
        print('[GeminiService ERROR] Stack trace: $stackTrace');
        throw Exception('Network error: $e');
      }

      // Parse response with error handling
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          
          // Validate response structure
          if (data['candidates'] == null || data['candidates'].isEmpty) {
            print('[GeminiService ERROR] No candidates in response');
            print('[GeminiService ERROR] Response body: ${response.body}');
            throw Exception('Invalid response structure: no candidates');
          }
          
          final candidate = data['candidates'][0];
          if (candidate['content'] == null || candidate['content']['parts'] == null) {
            print('[GeminiService ERROR] Invalid content structure');
            print('[GeminiService ERROR] Candidate: $candidate');
            throw Exception('Invalid response structure: missing content');
          }
          
          final generatedText = candidate['content']['parts'][0]['text'];
          print('[GeminiService] Response generated successfully');
          return generatedText.trim();
        } catch (e, stackTrace) {
          print('[GeminiService ERROR] Failed to parse response: $e');
          print('[GeminiService ERROR] Response body: ${response.body}');
          print('[GeminiService ERROR] Stack trace: $stackTrace');
          throw Exception('Failed to parse response: $e');
        }
      } else {
        print('[GeminiService ERROR] API returned error status: ${response.statusCode}');
        print('[GeminiService ERROR] Response body: ${response.body}');
        throw Exception('API error ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('[GeminiService ERROR] Error generating response: $e');
      print('[GeminiService ERROR] Stack trace: $stackTrace');
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
    // If we have a role-play scenario, use role-play specific prompts
    if (scenario != null) {
      return RolePlayPrompts.buildScenarioPrompt(
        scenario: scenario,
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        userLevel: userLevel,
      );
    }

    // Otherwise, use the general tutor prompts
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
    print('[GeminiService] Assessing user level...');
    print('[GeminiService] Sample text: "${sampleText.substring(0, sampleText.length > 30 ? 30 : sampleText.length)}..."');
    
    try {
      http.Response response;
      try {
        response = await _client.post(
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
      } catch (e, stackTrace) {
        print('[GeminiService ERROR] Level assessment request failed: $e');
        print('[GeminiService ERROR] Stack trace: $stackTrace');
        return 'intermediate';
      }

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          
          if (data['candidates'] == null || data['candidates'].isEmpty) {
            print('[GeminiService ERROR] No candidates in level assessment response');
            return 'intermediate';
          }
          
          final level = data['candidates'][0]['content']['parts'][0]['text']
              .trim()
              .toLowerCase();

          // Ensure we return a valid level
          if (['beginner', 'elementary', 'intermediate', 'advanced']
              .contains(level)) {
            print('[GeminiService] Level assessed as: $level');
            return level;
          } else {
            print('[GeminiService ERROR] Invalid level returned: $level');
          }
        } catch (e, stackTrace) {
          print('[GeminiService ERROR] Failed to parse level response: $e');
          print('[GeminiService ERROR] Stack trace: $stackTrace');
        }
      } else {
        print('[GeminiService ERROR] Level assessment API error: ${response.statusCode}');
      }

      return 'intermediate'; // Default fallback level
    } catch (e, stackTrace) {
      print('[GeminiService ERROR] Error assessing user level: $e');
      print('[GeminiService ERROR] Stack trace: $stackTrace');
      return 'intermediate'; // Default fallback level
    }
  }

  Future<Map<String, dynamic>> evaluateConversation({
    required String conversationHistory,
    required String topic,
  }) async {
    print('[GeminiService] Evaluating conversation for topic: $topic');
    final prompt = '''
You are an expert English language examiner and tutor.
Analyze the following English conversation between a user and an AI partner.
Topic/Scenario: $topic

Conversation History:
$conversationHistory

Please evaluate the user's responses (marked as "User:") across these exact criteria:
1. Grammar accuracy (grammar_score: 0-100)
2. Vocabulary usage and range (vocabulary_score: 0-100)
3. Fluency and sentence structure (fluency_score: 0-100)
4. Mistakes score (mistakes_score: 0-100, where 100 means no grammatical or spelling mistakes at all, and lower scores represent more errors)
5. Pronunciation score (pronunciation_score: 0-100, estimate the score based on phonetic clues in their transcription or flow. A realistic score from 0-100 matching their overall skill level)
6. Overall performance (overall_score: 0-100, the average of all criteria)
7. Detailed constructive feedback in English (feedback: detailed description of their performance, identifying specific mistakes, how to correct them, strengths, and recommendations for improvement)

You MUST respond with a single valid JSON object containing exactly the following keys:
- "grammar_score" (int)
- "vocabulary_score" (int)
- "fluency_score" (int)
- "mistakes_score" (int)
- "pronunciation_score" (int)
- "overall_score" (int)
- "feedback" (String)

Do not wrap the response in markdown blocks like ```json ... ```. Output ONLY the raw JSON string starting with { and ending with }.
''';

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl?key=${APIConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2,
            'responseMimeType': 'application/json',
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        text = text.trim();
        
        // Clean markdown backticks if any
        if (text.startsWith('```')) {
          text = text.replaceAll(RegExp(r'^```(json)?|```$'), '').trim();
        }
        
        return jsonDecode(text) as Map<String, dynamic>;
      } else {
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[GeminiService ERROR] Evaluation failed: $e');
      return {
        'grammar_score': 70,
        'vocabulary_score': 70,
        'fluency_score': 70,
        'mistakes_score': 30,
        'pronunciation_score': 70,
        'overall_score': 70,
        'feedback': 'We could not generate detailed feedback at this moment due to a network error. Keep practicing!',
      };
    }
  }

  void dispose() {
    _client.close();
  }
}
