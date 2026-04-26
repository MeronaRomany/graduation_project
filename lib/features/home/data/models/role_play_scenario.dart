import 'package:flutter/material.dart';

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

enum ScenarioCategory {
  dailyLife,
  travel,
  business,
  health,
  social,
}

class RolePlayScenario {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String systemPrompt;
  final String starterMessage;
  final DifficultyLevel difficulty;
  final ScenarioCategory category;
  final List<String> suggestedVocabulary;
  final List<String> commonPhrases;

  const RolePlayScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.systemPrompt,
    required this.starterMessage,
    required this.difficulty,
    required this.category,
    this.suggestedVocabulary = const [],
    this.commonPhrases = const [],
  });

  String get difficultyLabel {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
    }
  }

  Color get categoryColor {
    switch (category) {
      case ScenarioCategory.dailyLife:
        return const Color(0xFF667eea);
      case ScenarioCategory.travel:
        return const Color(0xFFf093fb);
      case ScenarioCategory.business:
        return const Color(0xFF4facfe);
      case ScenarioCategory.health:
        return const Color(0xFF43e97b);
      case ScenarioCategory.social:
        return const Color(0xFFfa709a);
    }
  }
}
