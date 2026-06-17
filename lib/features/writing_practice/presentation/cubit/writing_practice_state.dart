import 'package:equatable/equatable.dart';
import '../../data/models/writing_analysis_model.dart';
import '../../../home/data/models/role_play_scenario.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

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
  final List<ChatMessage> messages;
  final String userLevel;
  final bool isSendingMessage;

  const WritingPracticeLoaded({
    required this.scenarios,
    this.selectedScenario,
    this.messages = const [],
    required this.userLevel,
    this.isSendingMessage = false,
  });

  WritingPracticeLoaded copyWith({
    List<RolePlayScenario>? scenarios,
    RolePlayScenario? selectedScenario,
    List<ChatMessage>? messages,
    String? userLevel,
    bool? isSendingMessage,
  }) {
    return WritingPracticeLoaded(
      scenarios: scenarios ?? this.scenarios,
      selectedScenario: selectedScenario ?? this.selectedScenario,
      messages: messages ?? this.messages,
      userLevel: userLevel ?? this.userLevel,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
    );
  }

  @override
  List<Object?> get props => [scenarios, selectedScenario, messages, userLevel, isSendingMessage];
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
