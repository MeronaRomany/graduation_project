import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/models/learning_session_model.dart';
import 'package:graduation_app/services/firestore_service.dart';
import 'package:collection/collection.dart';

enum AnalysisFilter { last7Days, last30Days, last3Months, allTime }

class AnalysisDashboardState {
  final List<LearningSession> sessions;
  final bool isLoading;
  final String? error;
  final AnalysisFilter filter;

  AnalysisDashboardState({
    required this.sessions,
    this.isLoading = false,
    this.error,
    this.filter = AnalysisFilter.allTime,
  });

  List<LearningSession> get filteredSessions {
    final now = DateTime.now();
    switch (filter) {
      case AnalysisFilter.last7Days:
        return sessions.where((s) => s.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
      case AnalysisFilter.last30Days:
        return sessions.where((s) => s.date.isAfter(now.subtract(const Duration(days: 30)))).toList();
      case AnalysisFilter.last3Months:
        return sessions.where((s) => s.date.isAfter(now.subtract(const Duration(days: 90)))).toList();
      case AnalysisFilter.allTime:
        return sessions;
    }
  }

  double get avgSpeakingScore => _avg(SessionType.practice);
  double get avgWritingScore => _avg(SessionType.writing);

  double _avg(SessionType type) {
    final s = filteredSessions.where((s) => s.sessionType == type);
    if (s.isEmpty) return 0.0;
    return s.map((e) => e.overallScore).average;
  }

  AnalysisDashboardState copyWith({
    List<LearningSession>? sessions,
    bool? isLoading,
    String? error,
    AnalysisFilter? filter,
  }) {
    return AnalysisDashboardState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

class AnalysisDashboardCubit extends Cubit<AnalysisDashboardState> {
  final FireStoreService _fireStoreService;

  AnalysisDashboardCubit(this._fireStoreService)
      : super(AnalysisDashboardState(sessions: []));

  void loadAnalytics(String userId) {
    emit(state.copyWith(isLoading: true));
    _fireStoreService.streamLearningSessions(userId).listen((sessions) {
      emit(state.copyWith(sessions: sessions, isLoading: false));
    }, onError: (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    });
  }

  void setFilter(AnalysisFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  List<String> generateInsights() {
    final sessions = state.filteredSessions;
    if (sessions.isEmpty) return ["Start practicing to see insights!"];

    List<String> insights = [];
    final speakingAvg = state.avgSpeakingScore;
    final writingAvg = state.avgWritingScore;

    if (writingAvg > speakingAvg && speakingAvg > 0) {
      insights.add("Writing skills are stronger than speaking skills.");
    } else if (speakingAvg > writingAvg && writingAvg > 0) {
      insights.add("Speaking skills are stronger than writing skills.");
    }

    if (sessions.length > 5) {
      final recent = sessions.take(3).map((e) => e.overallScore).average;
      final older = sessions.skip(3).take(3).map((e) => e.overallScore).average;
      final improvement = recent - older;
      if (improvement > 5) {
        insights.add("Your overall performance has improved by ${improvement.toInt()}% recently!");
      }
    }

    final grammarAvg = sessions.map((e) => e.grammarScore).average;
    if (grammarAvg < 70) {
      insights.add("Consider focusing more on grammar exercises.");
    }

    return insights;
  }
}
