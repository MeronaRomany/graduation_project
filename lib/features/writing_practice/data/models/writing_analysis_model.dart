import 'mistake_model.dart';

class WritingAnalysis {
  final String correctedText;
  final int overallScore;
  final int grammarScore;
  final int vocabularyScore;
  final int fluencyScore;
  final List<String> improvementSuggestions;
  final List<Mistake> mistakes;

  WritingAnalysis({
    required this.correctedText,
    required this.overallScore,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.fluencyScore,
    required this.improvementSuggestions,
    required this.mistakes,
  });

  factory WritingAnalysis.fromJson(Map<String, dynamic> json) {
    return WritingAnalysis(
      correctedText: json['correctedText'] ?? '',
      overallScore: json['overallScore'] ?? 0,
      grammarScore: json['grammarScore'] ?? 0,
      vocabularyScore: json['vocabularyScore'] ?? 0,
      fluencyScore: json['fluencyScore'] ?? 0,
      improvementSuggestions: List<String>.from(json['improvementSuggestions'] ?? []),
      mistakes: (json['mistakes'] as List?)
              ?.map((m) => Mistake.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correctedText': correctedText,
      'overallScore': overallScore,
      'grammarScore': grammarScore,
      'vocabularyScore': vocabularyScore,
      'fluencyScore': fluencyScore,
      'improvementSuggestions': improvementSuggestions,
      'mistakes': mistakes.map((m) => m.toJson()).toList(),
    };
  }
}
