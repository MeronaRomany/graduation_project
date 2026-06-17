import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionType { practice, writing }

class LearningSession {
  final String? id;
  final String userId;
  final SessionType sessionType;
  final DateTime date;
  final int grammarScore;
  final int vocabularyScore;
  final int fluencyScore;
  final int overallScore;
  final int mistakesScore; 
  final int? pronunciationScore; // Nullable for writing
  final String feedback;

  LearningSession({
    this.id,
    required this.userId,
    required this.sessionType,
    required this.date,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.fluencyScore,
    required this.overallScore,
    required this.mistakesScore,
    this.pronunciationScore,
    required this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'session_type': sessionType.name,
      'date': Timestamp.fromDate(date),
      'grammar_score': grammarScore,
      'vocabulary_score': vocabularyScore,
      'fluency_score': fluencyScore,
      'overall_score': overallScore,
      'mistakes_score': mistakesScore,
      'pronunciation_score': pronunciationScore,
      'feedback': feedback,
    };
  }

  factory LearningSession.fromMap(Map<String, dynamic> map, String id) {
    return LearningSession(
      id: id,
      userId: map['userId'] ?? '',
      sessionType: map['session_type'] == 'writing' ? SessionType.writing : SessionType.practice,
      date: (map['date'] as Timestamp).toDate(),
      grammarScore: map['grammar_score'] ?? 0,
      vocabularyScore: map['vocabulary_score'] ?? 0,
      fluencyScore: map['fluency_score'] ?? 0,
      overallScore: map['overall_score'] ?? 0,
      mistakesScore: map['mistakes_score'] ?? 0,
      pronunciationScore: map['pronunciation_score'],
      feedback: map['feedback'] ?? '',
    );
  }
}
