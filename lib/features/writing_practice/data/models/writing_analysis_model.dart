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
      correctedText: json['correctedText']?.toString() ?? '',
      overallScore: _toInt(json['overallScore']),
      grammarScore: _toInt(json['grammarScore']),
      vocabularyScore: _toInt(json['vocabularyScore']),
      fluencyScore: _toInt(json['fluencyScore']),
      improvementSuggestions: _toStringList(json['improvementSuggestions']),
      mistakes: _toMistakeList(json['mistakes']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<Mistake> _toMistakeList(dynamic value) {
    if (value is List) {
      return value
          .map((m) {
            if (m is Map<String, dynamic>) {
              return Mistake.fromJson(m);
            }
            return null;
          })
          .whereType<Mistake>()
          .toList();
    }
    return [];
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
