import 'dart:convert';
import 'writing_practice_repo.dart';
import '../models/writing_analysis_model.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../home/data/models/role_play_scenario.dart';

class WritingPracticeRepositoryImpl implements WritingPracticeRepository {
  final GeminiService _geminiService;

  WritingPracticeRepositoryImpl(this._geminiService);

  @override
  Future<WritingAnalysis> analyzeWriting({
    required String text,
    required String scenarioTitle,
    required String userLevel,
  }) async {
    final response = await _geminiService.analyzeWriting(
      text: text,
      scenarioTitle: scenarioTitle,
      userLevel: userLevel,
    );

    final Map<String, dynamic> jsonMap = jsonDecode(response);
    return WritingAnalysis.fromJson(jsonMap);
  }

  @override
  Future<String> getChatResponse({
    required String userMessage,
    required String history,
    required RolePlayScenario scenario,
    required String userLevel,
  }) async {
    return await _geminiService.generateResponse(
      userMessage: userMessage,
      conversationHistory: history,
      scenario: scenario,
      userLevel: userLevel,
    );
  }
}
