import 'package:equatable/equatable.dart';
import '../../data/models/writing_analysis_model.dart';
import '../../../home/data/models/role_play_scenario.dart';

abstract class WritingPracticeState extends Equatable {
  const WritingPracticeState();

  @override
  List<Object?> get props => [];
}

class WritingPracticeInitial extends WritingPracticeState {}

class WritingPracticeLoading extends WritingPracticeState {}

class WritingPracticeLoaded extends WritingPracticeState {
  final List<RolePlayScenario> scenarios;
  final RolePlayScenario? selectedScenario;
  final String? selectedTask;
  final String userLevel;

  const WritingPracticeLoaded({
    required this.scenarios,
    this.selectedScenario,
    this.selectedTask,
    required this.userLevel,
  });

  WritingPracticeLoaded copyWith({
    List<RolePlayScenario>? scenarios,
    RolePlayScenario? selectedScenario,
    String? selectedTask,
    String? userLevel,
  }) {
    return WritingPracticeLoaded(
      scenarios: scenarios ?? this.scenarios,
      selectedScenario: selectedScenario ?? this.selectedScenario,
      selectedTask: selectedTask ?? this.selectedTask,
      userLevel: userLevel ?? this.userLevel,
    );
  }

  @override
  List<Object?> get props => [scenarios, selectedScenario, selectedTask, userLevel];
}

class WritingAnalysisSuccess extends WritingPracticeState {
  final WritingAnalysis analysis;
  const WritingAnalysisSuccess(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class WritingPracticeError extends WritingPracticeState {
  final String message;
  const WritingPracticeError(this.message);

  @override
  List<Object?> get props => [message];
}
