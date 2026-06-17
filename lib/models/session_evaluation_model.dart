class SessionEvaluation {
  final String id;
  final String userId;
  final int grammarScore;
  final int vocabularyScore;
  final int fluencyScore;
  final int mistakesScore;
  final int pronunciationScore;
  final int overallScore;
  final String feedback;
  final DateTime timestamp;
  final String topic;

  SessionEvaluation({
    required this.id,
    required this.userId,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.fluencyScore,
    required this.mistakesScore,
    required this.pronunciationScore,
    required this.overallScore,
    required this.feedback,
    required this.timestamp,
    required this.topic,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'grammar_score': grammarScore,
      'vocabulary_score': vocabularyScore,
      'fluency_score': fluencyScore,
      'mistakes_score': mistakesScore,
      'pronunciation_score': pronunciationScore,
      'overall_score': overallScore,
      'feedback': feedback,
      'timestamp': timestamp.toIso8601String(),
      'topic': topic,
    };
  }

  factory SessionEvaluation.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    final ts = map['timestamp'];
    if (ts is String) {
      parsedDate = DateTime.parse(ts);
    } else if (ts is DateTime) {
      parsedDate = ts;
    } else {
      // Handle cloud_firestore Timestamp dynamic checking safely without absolute dependency on Firestore library in Model
      try {
        parsedDate = (ts as dynamic).toDate();
      } catch (_) {
        try {
          parsedDate = DateTime.parse(ts.toString());
        } catch (_) {
          parsedDate = DateTime.now();
        }
      }
    }

    return SessionEvaluation(
      id: id,
      userId: map['userId'] ?? '',
      grammarScore: map['grammar_score'] is num ? (map['grammar_score'] as num).toInt() : 0,
      vocabularyScore: map['vocabulary_score'] is num ? (map['vocabulary_score'] as num).toInt() : 0,
      fluencyScore: map['fluency_score'] is num ? (map['fluency_score'] as num).toInt() : 0,
      mistakesScore: map['mistakes_score'] is num ? (map['mistakes_score'] as num).toInt() : 0,
      pronunciationScore: map['pronunciation_score'] is num ? (map['pronunciation_score'] as num).toInt() : 0,
      overallScore: map['overall_score'] is num ? (map['overall_score'] as num).toInt() : 0,
      feedback: map['feedback'] ?? '',
      timestamp: parsedDate,
      topic: map['topic'] ?? '',
    );
  }
}
