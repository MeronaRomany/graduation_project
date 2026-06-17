class Mistake {
  final String wrong;
  final String correct;
  final String reason;

  Mistake({
    required this.wrong,
    required this.correct,
    required this.reason,
  });

  factory Mistake.fromJson(Map<String, dynamic> json) {
    return Mistake(
      wrong: json['wrong'] ?? '',
      correct: json['correct'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wrong': wrong,
      'correct': correct,
      'reason': reason,
    };
  }
}
