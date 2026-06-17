import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/writing_practice_repo.dart';
import 'writing_practice_state.dart';
import '../../../home/data/models/role_play_scenario.dart';
import '../../../home/data/role_play_scenarios.dart';
import '../../../../models/learning_session_model.dart';
import '../../../../services/firestore_service.dart';

class WritingPracticeCubit extends Cubit<WritingPracticeState> {
  final WritingPracticeRepository _repository;
  final FireStoreService _fireStoreService;

  static const customScenario = RolePlayScenario(
    id: 'custom',
    title: 'Custom Topic',
    description: 'Write about anything you want',
    emoji: '📝',
    systemPrompt: 'You are an English teacher helping a student with their writing. Start a conversation about a topic they choose.',
    starterMessage: 'What would you like to write about today?',
    difficulty: DifficultyLevel.intermediate,
    category: ScenarioCategory.social,
    cefrLevel: CefrLevel.b12,
  );

  WritingPracticeCubit(this._repository, this._fireStoreService) : super(WritingPracticeInitial()) {
    loadScenarios();
  }

  void loadScenarios() {
    final allScenarios = [customScenario, ...rolePlayScenarios];
    emit(WritingPracticeLoaded(
      scenarios: allScenarios,
      selectedScenario: allScenarios.first,
      userLevel: 'Intermediate',
      messages: [
        ChatMessage(text: allScenarios.first.starterMessage, isUser: false),
      ],
    ));
  }

  void reset() {
    loadScenarios();
  }

  void selectScenario(RolePlayScenario scenario) {
    if (state is WritingPracticeLoaded) {
      final currentState = state as WritingPracticeLoaded;
      emit(currentState.copyWith(
        selectedScenario: scenario,
        messages: [
          ChatMessage(text: scenario.starterMessage, isUser: false),
        ],
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    final currentState = state;
    if (currentState is! WritingPracticeLoaded) return;
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: text, isUser: true);
    final updatedMessages = List<ChatMessage>.from(currentState.messages)..add(userMessage);

    emit(currentState.copyWith(
      messages: updatedMessages,
      isSendingMessage: true,
    ));

    try {
      final history = updatedMessages.map((m) => "${m.isUser ? 'User' : 'AI'}: ${m.text}").join('\n');
      
      final aiResponseText = await _repository.getChatResponse(
        userMessage: text,
        history: history,
        scenario: currentState.selectedScenario!,
        userLevel: currentState.userLevel,
      );

      final aiMessage = ChatMessage(text: aiResponseText, isUser: false);
      
      if (state is WritingPracticeLoaded) {
        final latestState = state as WritingPracticeLoaded;
        emit(latestState.copyWith(
          messages: List<ChatMessage>.from(latestState.messages)..add(aiMessage),
          isSendingMessage: false,
        ));
      }
    } catch (e) {
      if (state is WritingPracticeLoaded) {
        emit((state as WritingPracticeLoaded).copyWith(isSendingMessage: false));
      }
      emit(WritingPracticeError(e.toString()));
    }
  }

  Future<void> finishAndAnalyze() async {
    final currentState = state;
    if (currentState is! WritingPracticeLoaded) return;
    
    final userMessages = currentState.messages
        .where((m) => m.isUser)
        .map((m) => m.text)
        .join('\n');

    if (userMessages.trim().isEmpty) {
      emit(const WritingPracticeError('Please write something first!'));
      return;
    }

    final previousLoadedState = currentState;
    emit(WritingPracticeLoading());

    try {
      final analysis = await _repository.analyzeWriting(
        text: userMessages,
        scenarioTitle: currentState.selectedScenario?.title ?? 'General',
        userLevel: currentState.userLevel,
      );

      // Save to Firebase
      final user = await _fireStoreService.userModel;
      final session = LearningSession(
        userId: user.uid,
        sessionType: SessionType.writing,
        date: DateTime.now(),
        grammarScore: analysis.grammarScore,
        vocabularyScore: analysis.vocabularyScore,
        fluencyScore: analysis.fluencyScore,
        overallScore: analysis.overallScore,
        mistakesScore: analysis.mistakes.length,
        feedback: analysis.improvementSuggestions.join('\n'),
      );
      await _fireStoreService.saveLearningSession(session);

      emit(WritingAnalysisSuccess(analysis));
    } catch (e) {
      emit(WritingPracticeError(e.toString()));
      emit(previousLoadedState);
    }
  }
}
