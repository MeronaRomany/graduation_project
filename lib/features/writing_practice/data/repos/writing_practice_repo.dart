import '../../../home/data/models/role_play_scenario.dart';
import '../models/writing_analysis_model.dart';

abstract class WritingPracticeRepository {
  Future<WritingAnalysis> analyzeWriting({
    required String text,
    required String scenarioTitle,
    required String userLevel,
  });

  Future<String> getChatResponse({
    required String userMessage,
    required String history,
    required RolePlayScenario scenario,
    required String userLevel,
  });
}
