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

enum CefrLevel {
  a11, // A1.1 - Absolute beginner
  a12, // A1.2 - Beginner
  a21, // A2.1 - Elementary
  a22, // A2.2 - Elementary+
  b11, // B1.1 - Pre-intermediate
  b12, // B1.2 - Intermediate
  b21, // B2.1 - Upper-intermediate
  b22, // B2.2 - Upper-intermediate+
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
  final CefrLevel cefrLevel;
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
    required this.cefrLevel,
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

  String get cefrLabel {
    switch (cefrLevel) {
      case CefrLevel.a11:
        return 'A1.1';
      case CefrLevel.a12:
        return 'A1.2';
      case CefrLevel.a21:
        return 'A2.1';
      case CefrLevel.a22:
        return 'A2.2';
      case CefrLevel.b11:
        return 'B1.1';
      case CefrLevel.b12:
        return 'B1.2';
      case CefrLevel.b21:
        return 'B2.1';
      case CefrLevel.b22:
        return 'B2.2';
    }
  }

  String get cefrDescription {
    switch (cefrLevel) {
      case CefrLevel.a11:
        return 'Absolute Beginner - Basic greetings & simple phrases';
      case CefrLevel.a12:
        return 'Beginner - Simple everyday expressions';
      case CefrLevel.a21:
        return 'Elementary - Short social interactions';
      case CefrLevel.a22:
        return 'Elementary+ - Routine tasks & simple descriptions';
      case CefrLevel.b11:
        return 'Pre-intermediate - Handle travel & familiar topics';
      case CefrLevel.b12:
        return 'Intermediate - Connected text & general topics';
      case CefrLevel.b21:
        return 'Upper-intermediate - Complex texts & detailed arguments';
      case CefrLevel.b22:
        return 'Upper-intermediate+ - Fluent & spontaneous conversation';
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

  Color get cefrColor {
    switch (cefrLevel) {
      case CefrLevel.a11:
      case CefrLevel.a12:
      case CefrLevel.a21:
      case CefrLevel.a22:
        return const Color(0xFF4CAF50);
      case CefrLevel.b11:
      case CefrLevel.b12:
        return const Color(0xFFFF9800);
      case CefrLevel.b21:
      case CefrLevel.b22:
        return const Color(0xFFE53935);
    }
  }

  Color get categoryColor {
    switch (category) {
      case ScenarioCategory.dailyLife:
        return const Color(0xFF667eea);
      case ScenarioCategory.travel:
        return const Color(0xFF667eea);
      case ScenarioCategory.business:
        return const Color(0xFF667eea);
      case ScenarioCategory.health:
        return const Color(0xFF667eea);
      case ScenarioCategory.social:
        return const Color(0xFF667eea);
    }
  }

  static List<RolePlayScenario> getByCefrLevel(
      List<RolePlayScenario> scenarios, CefrLevel level) {
    return scenarios.where((s) => s.cefrLevel == level).toList();
  }

  static List<CefrLevel> getAvailableLevels(
      List<RolePlayScenario> scenarios) {
    final levels = scenarios.map((s) => s.cefrLevel).toSet().toList();
    levels.sort((a, b) => a.index.compareTo(b.index));
    return levels;
  }
}
