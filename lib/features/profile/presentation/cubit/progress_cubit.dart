import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'progress_state.dart';
import '../../../../../services/firestore_service.dart';
import '../../../../../models/session_evaluation_model.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final FireStoreService _fireStoreService;

  ProgressCubit({FireStoreService? fireStoreService})
      : _fireStoreService = fireStoreService ?? FireStoreService(),
        super(ProgressInitial());

  Future<void> loadProgress() async {
    emit(ProgressLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const ProgressError("No user logged in"));
        return;
      }

      final evaluations = await _fireStoreService.getSessionEvaluations(user.uid);

      if (evaluations.isEmpty) {
        emit(const ProgressLoaded(
          evaluations: [],
          selectedTimeSpan: 'all',
          averageScores: {
            'grammar': 0.0,
            'vocabulary': 0.0,
            'fluency': 0.0,
            'mistakes': 0.0,
            'pronunciation': 0.0,
            'overall': 0.0,
          },
          insights: [
            "Welcome to your progress dashboard! Complete a speaking session with the AI Tutor and click 'Evaluate Session' to see your metrics here.",
            "Visualizing your learning path helps you target specific speaking skills like Fluency and Vocabulary.",
          ],
        ));
        return;
      }

      // Compute aggregates
      double totalGrammar = 0;
      double totalVocab = 0;
      double totalFluency = 0;
      double totalMistakes = 0;
      double totalPron = 0;
      double totalOverall = 0;

      for (var eval in evaluations) {
        totalGrammar += eval.grammarScore;
        totalVocab += eval.vocabularyScore;
        totalFluency += eval.fluencyScore;
        totalMistakes += eval.mistakesScore;
        totalPron += eval.pronunciationScore;
        totalOverall += eval.overallScore;
      }

      final count = evaluations.length.toDouble();
      final averageScores = {
        'grammar': totalGrammar / count,
        'vocabulary': totalVocab / count,
        'fluency': totalFluency / count,
        'mistakes': totalMistakes / count,
        'pronunciation': totalPron / count,
        'overall': totalOverall / count,
      };

      // Generate Insights
      final insights = _generateInsights(evaluations, averageScores);

      emit(ProgressLoaded(
        evaluations: evaluations,
        selectedTimeSpan: 'all',
        averageScores: averageScores,
        insights: insights,
      ));
    } catch (e) {
      log("Error loading progress data", error: e);
      emit(ProgressError("Failed to load progress details: ${e.toString()}"));
    }
  }

  void changeTimeSpan(String newTimeSpan) {
    final currentState = state;
    if (currentState is ProgressLoaded) {
      emit(currentState.copyWith(selectedTimeSpan: newTimeSpan));
    }
  }

  List<String> _generateInsights(
      List<SessionEvaluation> evals, Map<String, double> averages) {
    final list = <String>[];

    // Insight 1: Overall Milestone
    final overall = averages['overall'] ?? 0.0;
    if (overall >= 85) {
      list.add("🏆 Outstanding progress! Your overall score is ${overall.toStringAsFixed(1)}%. You demonstrate advanced vocabulary and grammar usage.");
    } else if (overall >= 70) {
      list.add("⭐ Great job! You are performing at a solid intermediate level with an overall score of ${overall.toStringAsFixed(1)}%.");
    } else {
      list.add("💪 Keep practicing! Focusing on daily conversations will rapidly increase your confidence and score.");
    }

    // Insight 2: Find weakest area and give action step
    final keys = ['grammar', 'vocabulary', 'fluency', 'pronunciation'];
    String weakest = 'grammar';
    double minVal = averages['grammar'] ?? 100.0;
    for (var k in keys) {
      final val = averages[k] ?? 100.0;
      if (val < minVal) {
        minVal = val;
        weakest = k;
      }
    }

    switch (weakest) {
      case 'grammar':
        list.add("💡 Focus Area: Grammar is your lowest category (${minVal.toStringAsFixed(1)}%). Try writing longer sentences and checking tense consistency.");
        break;
      case 'vocabulary':
        list.add("💡 Focus Area: Vocabulary is your lowest category (${minVal.toStringAsFixed(1)}%). Try practicing specific roleplays like 'Job Interview' or 'Grocery' to learn scenario-specific terms.");
        break;
      case 'fluency':
        list.add("💡 Focus Area: Fluency is your lowest category (${minVal.toStringAsFixed(1)}%). Try to speak continuously without pausing, even if you make minor mistakes.");
        break;
      case 'pronunciation':
        list.add("💡 Focus Area: Pronunciation is your lowest category (${minVal.toStringAsFixed(1)}%). Read the AI tutor's text aloud to copy native rhythm and intonation.");
        break;
    }

    // Insight 3: Progress trend
    if (evals.length >= 2) {
      final latest = evals.first.overallScore;
      final oldest = evals.last.overallScore;
      final diff = latest - oldest;
      if (diff > 0) {
        list.add("📈 Positive Trend: Your overall score has improved by $diff points since your first session! Keep up the momentum.");
      } else if (diff < 0) {
        list.add("📉 Consistency Tip: Try to practice consistently. A short, focused session every day is better than long, sporadic ones.");
      } else {
        list.add("🎯 Consistency Check: You are maintaining a stable performance. Push yourself by attempting harder topics and advanced expressions.");
      }
    } else {
      list.add("🎯 Goal: Try to practice 3 days in a row to start tracking weekly improvement trends!");
    }

    return list;
  }
}
