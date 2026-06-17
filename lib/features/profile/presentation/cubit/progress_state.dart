import 'package:equatable/equatable.dart';
import '../../../../../models/session_evaluation_model.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final List<SessionEvaluation> evaluations;
  final String selectedTimeSpan; // 'days', 'weeks', 'months', 'all'
  final Map<String, double> averageScores;
  final List<String> insights;

  const ProgressLoaded({
    required this.evaluations,
    required this.selectedTimeSpan,
    required this.averageScores,
    required this.insights,
  });

  ProgressLoaded copyWith({
    List<SessionEvaluation>? evaluations,
    String? selectedTimeSpan,
    Map<String, double>? averageScores,
    List<String>? insights,
  }) {
    return ProgressLoaded(
      evaluations: evaluations ?? this.evaluations,
      selectedTimeSpan: selectedTimeSpan ?? this.selectedTimeSpan,
      averageScores: averageScores ?? this.averageScores,
      insights: insights ?? this.insights,
    );
  }

  @override
  List<Object?> get props => [evaluations, selectedTimeSpan, averageScores, insights];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}
