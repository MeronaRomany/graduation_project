import '../models/writing_analysis_model.dart';

abstract class WritingPracticeRepository {
  Future<WritingAnalysis> analyzeWriting({
    required String text,
    required String scenarioTitle,
    required String userLevel,
  });
}
