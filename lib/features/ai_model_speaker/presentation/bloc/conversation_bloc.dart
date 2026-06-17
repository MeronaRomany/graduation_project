import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../home/data/models/role_play_scenario.dart';
import '../../../home/data/role_play_scenarios.dart';


abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeConversation extends ConversationEvent {
  final String scenarioName;
  const InitializeConversation({this.scenarioName = 'general'});

  @override
  List<Object?> get props => [scenarioName];
}

class StartListening extends ConversationEvent {}
class StopListening extends ConversationEvent {}

class SpeechRecognized extends ConversationEvent {
  final String text;
  const SpeechRecognized(this.text);

  @override
  List<Object?> get props => [text];
}

class SendMessage extends ConversationEvent {
  final String message;
  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class SpeakAIResponse extends ConversationEvent {
  final String text;
  const SpeakAIResponse(this.text);

  @override
  List<Object?> get props => [text];
}

class StopAISpeech extends ConversationEvent {}

class InterruptAI extends ConversationEvent {}

class StartSpeaking extends ConversationEvent {}
class StopSpeaking extends ConversationEvent {}

class ResetConversation extends ConversationEvent {}

class _ServiceError extends ConversationEvent {
  final String message;
  const _ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateUserLevel extends ConversationEvent {
  final String level;
  const UpdateUserLevel(this.level);

  @override
  List<Object?> get props => [level];
}

// ───────────────────────────────
// STATE
// ───────────────────────────────

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationError extends ConversationState {
  final String message;
  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConversationMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? level;


  const ConversationMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
     this.level
  });

  @override
  List<Object?> get props => [text, isUser, timestamp];
}

class ConversationReady extends ConversationState {
  final String userLevel;
  final String currentTopic;
  final List<ConversationMessage> messages;
  final bool isListening;
  final bool isAISpeaking;
  final bool isProcessing;
  final bool isGeneratingAudio;

  const ConversationReady({
    this.userLevel = 'intermediate',
    this.currentTopic = 'general',
    this.messages = const [],
    this.isListening = false,
    this.isAISpeaking = false,
    this.isProcessing = false,
    this.isGeneratingAudio = false,
  });

  ConversationReady copyWith({
    String? userLevel,
    String? currentTopic,
    List<ConversationMessage>? messages,
    bool? isListening,
    bool? isAISpeaking,
    bool? isProcessing,
    bool? isGeneratingAudio,
  }) {
    return ConversationReady(
      userLevel: userLevel ?? this.userLevel,
      currentTopic: currentTopic ?? this.currentTopic,
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isAISpeaking: isAISpeaking ?? this.isAISpeaking,
      isProcessing: isProcessing ?? this.isProcessing,
      isGeneratingAudio: isGeneratingAudio ?? this.isGeneratingAudio,
    );
  }

  @override
  List<Object?> get props => [
    userLevel,
    currentTopic,
    messages,
    isListening,
    isAISpeaking,
    isProcessing,
    isGeneratingAudio,
  ];
}


class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GeminiService _geminiService;
  final SpeechService _speechService;
  final TTSService _ttsService;

  Timer? _autoStopTimer;
  String _conversationHistory = '';
  String _currentUserLevel = 'intermediate';
  bool _isProcessing = false;

  late final StreamSubscription _speechSub;
  late final StreamSubscription _speechResultSub;
  late final StreamSubscription _ttsSub;
  late final StreamSubscription _ttsErrorSub;

  static const String _greeting =
      "Hello! I'm your English practice partner. What would you like to talk about today?";

  ConversationBloc(
      this._geminiService,
      this._speechService,
      this._ttsService,
      ) : super(ConversationInitial()) {
    on<InitializeConversation>(_onInit);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<SpeechRecognized>(_onSpeechRecognized);
    on<SendMessage>(_onSendMessage);
    on<SpeakAIResponse>(_onSpeakAI);
    on<StopAISpeech>(_onStopSpeech);
    on<InterruptAI>(_onInterrupt);
    on<StartSpeaking>(_onStartSpeaking);
    on<StopSpeaking>(_onStopSpeaking);
    on<ResetConversation>(_onReset);
    on<UpdateUserLevel>(_onUpdateLevel);
    on<_ServiceError>(_onError);

    _speechSub = _speechService.state.listen((state) {
      if (state == SpeechState.completed) {
        add(StopListening());
      }
    });

    _speechResultSub = _speechService.result.listen((text) {
      if (text.trim().isNotEmpty) {
        add(SpeechRecognized(text));
      }
    });

    _ttsSub = _ttsService.state.listen((state) {
      if (state == TTSState.speaking) {
        add(StartSpeaking());
      } else {
        add(StopSpeaking());
      }
    });

    _ttsErrorSub = _ttsService.error.listen((err) {
      add(_ServiceError(err));
    });
  }


  Future<void> _onInit(
      InitializeConversation event,
      Emitter<ConversationState> emit,
      ) async {
    emit(ConversationLoading());

    await _speechService.initialize();
    await _ttsService.initialize();

    String topic = event.scenarioName;

    RolePlayScenario? scenario;
    try {
      scenario = rolePlayScenarios.firstWhere(
            (s) => s.id == topic,
      );
    } catch (_) {}

    final String initialText = scenario != null 
        ? scenario.starterMessage 
        : _greeting;

    _conversationHistory = "AI: $initialText";

    final message = ConversationMessage(
      text: initialText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    emit(ConversationReady(
      currentTopic: topic,
      messages: [message],
      userLevel: _currentUserLevel,
    ));

    add(SpeakAIResponse(initialText));
  }


  Future<void> _onStartListening(
      StartListening event,
      Emitter<ConversationState> emit,
      ) async {
    final state = this.state;
    if (state is! ConversationReady) return;

    await _speechService.startListening();

    emit(state.copyWith(isListening: true));

    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(const Duration(seconds: 10), () {
      add(StopListening());
    });
  }

  Future<void> _onStopListening(
      StopListening event,
      Emitter<ConversationState> emit,
      ) async {
    _autoStopTimer?.cancel();
    await _speechService.stopListening();

    final state = this.state;
    if (state is ConversationReady) {
      emit(state.copyWith(isListening: false));
    }
  }

  Future<void> _onSpeechRecognized(
      SpeechRecognized event,
      Emitter<ConversationState> emit,
      ) async {
    final state = this.state;
    if (state is! ConversationReady) return;

    final userMsg = ConversationMessage(
      text: event.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMsg],
    ));

    add(SendMessage(event.text));
  }


  Future<void> _onSendMessage(
      SendMessage event,
      Emitter<ConversationState> emit,
      ) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final state = this.state;
      if (state is! ConversationReady) return;

      emit(state.copyWith(isProcessing: true));

      _conversationHistory += "\nUser: ${event.message}";

      RolePlayScenario scenario;

      try {
        scenario = rolePlayScenarios.firstWhere(
              (s) => s.id == state.currentTopic,
        );
      } catch (_) {
        scenario = RolePlayScenario(
          id: 'custom',
          title: state.currentTopic,
          systemPrompt:
          "You are a roleplay partner for ${state.currentTopic}",
          description: "Custom scenario",
          emoji: "✨",
          starterMessage: "",
          difficulty: DifficultyLevel.beginner,
          category: ScenarioCategory.dailyLife,
          cefrLevel: CefrLevel.a12,
        );
      }

      final response = await _geminiService.generateResponse(
        userMessage: event.message,
        conversationHistory: _conversationHistory,
        userLevel: _currentUserLevel,
        scenario: scenario,
      );

      _conversationHistory += "\nAI: $response";

      final aiMsg = ConversationMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final newState = this.state;
      if (newState is ConversationReady) {
        emit(newState.copyWith(
          messages: [...newState.messages, aiMsg],
          isProcessing: false,
        ));
      }

      add(SpeakAIResponse(response));
    } catch (e) {
      final newState = this.state;
      if (newState is ConversationReady) {
        emit(newState.copyWith(isProcessing: false));
      }
      add(_ServiceError(e.toString()));
    } finally {
      _isProcessing = false;
    }
  }


  Future<void> _onSpeakAI(
      SpeakAIResponse event,
      Emitter<ConversationState> emit,
      ) async {
    final state = this.state;
    if (state is ConversationReady) {
      emit(state.copyWith(isGeneratingAudio: true));
    }
    await _ttsService.speak(event.text);
  }

  Future<void> _onStopSpeech(
      StopAISpeech event,
      Emitter<ConversationState> emit,
      ) async {
    await _ttsService.stop();
  }

  Future<void> _onInterrupt(
      InterruptAI event,
      Emitter<ConversationState> emit,
      ) async {
    await _ttsService.stop();

    final state = this.state;
    if (state is ConversationReady) {
      emit(state.copyWith(isAISpeaking: false, isGeneratingAudio: false));
    }
  }

  Future<void> _onStartSpeaking(
      StartSpeaking event,
      Emitter<ConversationState> emit,
      ) async {
    final state = this.state;
    if (state is ConversationReady) {
      emit(state.copyWith(isAISpeaking: true, isGeneratingAudio: false));
    }
  }

  Future<void> _onStopSpeaking(
      StopSpeaking event,
      Emitter<ConversationState> emit,
      ) async {
    final state = this.state;
    if (state is ConversationReady) {
      emit(state.copyWith(isAISpeaking: false, isGeneratingAudio: false));
    }
  }

  Future<void> _onReset(
      ResetConversation event,
      Emitter<ConversationState> emit,
      ) async {
    _currentUserLevel = 'intermediate';

    final currentState = this.state;
    String topic = 'general';
    if (currentState is ConversationReady) {
      topic = currentState.currentTopic;
    }

    RolePlayScenario? scenario;
    try {
      scenario = rolePlayScenarios.firstWhere(
            (s) => s.id == topic,
      );
    } catch (_) {}

    final String initialText = scenario != null 
        ? scenario.starterMessage 
        : _greeting;

    _conversationHistory = "AI: $initialText";

    emit(ConversationReady(
      currentTopic: topic,
      messages: [
        ConversationMessage(
          text: initialText,
          isUser: false,
          timestamp: DateTime.now(),
        )
      ],
      userLevel: _currentUserLevel,
    ));

    add(SpeakAIResponse(initialText));
  }

  Future<void> _onUpdateLevel(
      UpdateUserLevel event,
      Emitter<ConversationState> emit,
      ) async {
    _currentUserLevel = event.level;

    final state = this.state;
    if (state is ConversationReady) {
      emit(state.copyWith(userLevel: event.level));
    }
  }

  // ───────────────────────────────
  // ERROR
  // ───────────────────────────────

  Future<void> _onError(
      _ServiceError event,
      Emitter<ConversationState> emit,
      ) async {
    emit(ConversationError(event.message));
  }

  @override
  Future<void> close() async {
    _autoStopTimer?.cancel();

    await _speechSub.cancel();
    await _speechResultSub.cancel();
    await _ttsSub.cancel();
    await _ttsErrorSub.cancel();

    return super.close();
  }
}