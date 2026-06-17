import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/writing_practice_repo.dart';
import 'writing_practice_state.dart';
import '../../../home/data/models/role_play_scenario.dart';
import '../../../home/data/role_play_scenarios.dart';

class WritingPracticeCubit extends Cubit<WritingPracticeState> {
  final WritingPracticeRepository _repository;

  WritingPracticeCubit(this._repository) : super(WritingPracticeInitial()) {
    loadScenarios();
  }

  void loadScenarios() {
    // In a real app, user level might come from a ProfileCubit
    emit(WritingPracticeLoaded(
      scenarios: rolePlayScenarios,
      userLevel: 'Intermediate',
    ));
  }

  void selectScenario(RolePlayScenario scenario) {
    if (state is WritingPracticeLoaded) {
      final currentState = state as WritingPracticeLoaded;
      emit(currentState.copyWith(
        selectedScenario: scenario,
        selectedTask: null,
      ));
    }
  }

  void selectTask(String task) {
    if (state is WritingPracticeLoaded) {
      final currentState = state as WritingPracticeLoaded;
      emit(currentState.copyWith(selectedTask: task));
    }
  }

  Future<void> analyzeWriting(String text) async {
    if (state is! WritingPracticeLoaded) return;
    final currentState = state as WritingPracticeLoaded;
    
    if (currentState.selectedScenario == null) {
      emit(const WritingPracticeError('Please select a scenario first.'));
      return;
    }

    final scenario = currentState.selectedScenario!;
    
    emit(WritingPracticeLoading());

    try {
      final analysis = await _repository.analyzeWriting(
        text: text,
        scenarioTitle: scenario.title,
        userLevel: currentState.userLevel,
      );
      emit(WritingAnalysisSuccess(analysis));
    } catch (e) {
      emit(WritingPracticeError(e.toString()));
      // Recover to loaded state so user can try again
      emit(currentState);
    }
  }
}
