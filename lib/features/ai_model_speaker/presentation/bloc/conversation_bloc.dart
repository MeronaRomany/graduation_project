import 'dart:async';
import 'dart:typed_data'; // تم إضافتها لضمان التوافق مع البيانات الصوتية
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../home/data/models/role_play_scenario.dart';
import '../../../home/data/role_play_scenarios.dart';

// ─────────────────────────────────────────────
// Events
// ─────────────────────────────────────────────

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

// 🟢 تعديل: إضافة باراميتر يحمل اسم السيناريو عند البداية
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

class ReceiveAIResponse extends ConversationEvent {
  final String response;
  const ReceiveAIResponse(this.response);

  @override
  List<Object?> get props => [response];
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

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationReady extends ConversationState {
  final String userLevel;
  final String currentTopic;
  final List<ConversationMessage> messages;
  final bool isListening;
  final bool isAISpeaking;
  final SpeechState speechState;
  final TTSState ttsState;

  const ConversationReady({
    this.userLevel = 'intermediate',
    this.currentTopic = 'general',
    this.messages = const [],
    this.isListening = false,
    this.isAISpeaking = false,
    this.speechState = SpeechState.idle,
    this.ttsState = TTSState.idle,
  });

  @override
  List<Object?> get props => [
    userLevel,
    currentTopic,
    messages,
    isListening,
    isAISpeaking,
    speechState,
    ttsState,
  ];

  ConversationReady copyWith({
    String? userLevel,
    String? currentTopic,
    List<ConversationMessage>? messages,
    bool? isListening,
    bool? isAISpeaking,
    SpeechState? speechState,
    TTSState? ttsState,
  }) {
    return ConversationReady(
      userLevel: userLevel ?? this.userLevel,
      currentTopic: currentTopic ?? this.currentTopic,
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isAISpeaking: isAISpeaking ?? this.isAISpeaking,
      speechState: speechState ?? this.speechState,
      ttsState: ttsState ?? this.ttsState,
    );
  }
}

class ConversationError extends ConversationState {
  final String message;
  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────
// Message Model
// ─────────────────────────────────────────────

class ConversationMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? level;

  const ConversationMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.level,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp, level];
}

// ─────────────────────────────────────────────
// BLoC Class
// ─────────────────────────────────────────────

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GeminiService _geminiService;
  final SpeechService _speechService;
  final TTSService _ttsService;

  Timer? _autoStopTimer;
  String _conversationHistory = '';
  String _currentUserLevel = 'intermediate';
  bool _isProcessingResponse = false;

  late final StreamSubscription<SpeechState> _speechStateSub;
  late final StreamSubscription<String> _speechResultSub;
  late final StreamSubscription<String> _speechErrorSub;
  late final StreamSubscription<TTSState> _ttsStateSub;
  late final StreamSubscription<String> _ttsErrorSub;

  static const String _greeting =
      "Hello! I'm your English practice partner. "
      "I'm excited to help you improve your English skills. "
      "What would you like to talk about today?";

  ConversationBloc(
      this._geminiService,
      this._speechService,
      this._ttsService,
      ) : super(ConversationInitial()) {
    on<InitializeConversation>(_onInitializeConversation);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<SpeechRecognized>(_onSpeechRecognized);
    on<SendMessage>(_onSendMessage);
    on<ReceiveAIResponse>(_onReceiveAIResponse);
    on<SpeakAIResponse>(_onSpeakAIResponse);
    on<StopAISpeech>(_onStopAISpeech);
    on<InterruptAI>(_onInterruptAI);
    on<StartSpeaking>(_onStartSpeaking);
    on<StopSpeaking>(_onStopSpeaking);
    on<ResetConversation>(_onResetConversation);
    on<UpdateUserLevel>(_onUpdateUserLevel);
    on<_ServiceError>(_onServiceError);

    _speechStateSub = _speechService.state.listen((speechState) {
      if (speechState == SpeechState.completed) {
        add(StopListening());
      }
    });

    _speechResultSub = _speechService.result.listen((text) {
      if (text.trim().isNotEmpty) {
        add(SpeechRecognized(text));
      }
    });

    _speechErrorSub = _speechService.error.listen((err) {
      add(_ServiceError(err));
    });

    _ttsStateSub = _ttsService.state.listen((ttsState) {
      if (ttsState == TTSState.speaking) {
        add(StartSpeaking());
      } else if (ttsState == TTSState.idle) {
        add(StopSpeaking());
      }
    });

    _ttsErrorSub = _ttsService.error.listen((err) {
      add(_ServiceError(err));
    });
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onInitializeConversation(
      InitializeConversation event,
      Emitter<ConversationState> emit,
      ) async {
    emit(ConversationLoading());

    try {
      final speechOk = await _speechService.initialize();
      final ttsOk = await _ttsService.initialize();

      if (!speechOk || !ttsOk) {
        emit(const ConversationError('Failed to initialize services'));
        return;
      }

      // 🟢 تعديل: تغيير رسالة الترحيب المبدئية بناءً على السيناريو المختار (سواء جاهز أو مخصص)
      String initialGreeting = _greeting;
      if (event.scenarioName != 'general') {
        initialGreeting = "Hello! Let's start our role-play scenario for '${event.scenarioName}'. I am ready, whenever you are!";
      }

      final initialMessage = ConversationMessage(
        text: initialGreeting,
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(ConversationReady(
        messages: [initialMessage],
        userLevel: _currentUserLevel,
        currentTopic: event.scenarioName, // 🟢 حفظ اسم السيناريو في الـ State
      ));
    } catch (e) {
      emit(ConversationError('Initialization failed: $e'));
    }
  }

  Future<void> _onStartListening(
      StartListening event,
      Emitter<ConversationState> emit,
      ) async {
    final currentState = state;
    if (currentState is! ConversationReady) return;

    if (currentState.isAISpeaking) {
      await _ttsService.stop();
    }

    try {
      await _speechService.startListening();
      emit(currentState.copyWith(
        isListening: true,
        speechState: SpeechState.listening,
      ));

      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(const Duration(seconds: 10), () {
        add(StopListening());
      });
    } catch (e) {
      add(_ServiceError('Could not start listening: $e'));
    }
  }

  Future<void> _onStopListening(
      StopListening event,
      Emitter<ConversationState> emit,
      ) async {
    _autoStopTimer?.cancel();
    await _speechService.stopListening();

    final currentState = state;
    if (currentState is ConversationReady) {
      emit(currentState.copyWith(
        isListening: false,
        speechState: SpeechState.idle,
      ));
    }
  }

  Future<void> _onSpeechRecognized(
      SpeechRecognized event,
      Emitter<ConversationState> emit,
      ) async {
    final currentState = state;
    if (currentState is! ConversationReady) return;

    final userMessage = ConversationMessage(
      text: event.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(currentState.copyWith(
      messages: [...currentState.messages, userMessage],
    ));

    _assessAndUpdateLevel(event.text);
    add(SendMessage(event.text));
  }

  Future<void> _onSendMessage(
      SendMessage event,
      Emitter<ConversationState> emit,
      ) async {
    if (_isProcessingResponse) return;
    _isProcessingResponse = true;

    try {
      final currentState = state;
      if (currentState is! ConversationReady) return;

      _conversationHistory += '\nUser: ${event.message}';

      // 🛠️ التعديل السحري هنا لدعم الـ Custom Scenario تلقائياً:
      RolePlayScenario currentScenarioObject;
      try {
        currentScenarioObject = rolePlayScenarios.firstWhere(
              (s) => s.id == currentState.currentTopic,
        );
      } catch (_) {
        currentScenarioObject = RolePlayScenario(
          id: 'custom_topic',
          title: currentState.currentTopic,
          systemPrompt: "The user has defined a custom roleplay scenario: '${currentState.currentTopic}'. "
              "Act as a professional conversation partner for this specific setting. "
              "Adopt an appropriate role that matches this topic perfectly and engage naturally.",

          description: "Custom user-defined scenario for practice.",
          emoji: "✨",
          starterMessage: "Hello! Let's start our custom role-play about: ${currentState.currentTopic}.",
          difficulty: DifficultyLevel.beginner,
          category: ScenarioCategory.dailyLife,
        );
      }

      final aiResponse = await _geminiService.generateResponse(
        userMessage: event.message,
        conversationHistory: _conversationHistory,
        userLevel: _currentUserLevel,
        scenario: currentScenarioObject, // تم التمرير بنجاح في الحالتين!
      );

      _conversationHistory += '\nAI: $aiResponse';

      final aiMessage = ConversationMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final freshState = state;
      if (freshState is ConversationReady) {
        emit(freshState.copyWith(
          messages: [...freshState.messages, aiMessage],
        ));
      }

      add(SpeakAIResponse(aiResponse));
    } catch (e) {
      emit(ConversationError('Failed to get AI response: $e'));
    } finally {
      _isProcessingResponse = false;
    }
  }

  Future<void> _onReceiveAIResponse(
      ReceiveAIResponse event,
      Emitter<ConversationState> emit,
      ) async {
    final currentState = state;
    if (currentState is! ConversationReady) return;

    final aiMessage = ConversationMessage(
      text: event.response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    emit(currentState.copyWith(
      messages: [...currentState.messages, aiMessage],
    ));
  }

  Future<void> _onSpeakAIResponse(
      SpeakAIResponse event,
      Emitter<ConversationState> emit,
      ) async {
    await _ttsService.speak(event.text);
  }

  Future<void> _onStopAISpeech(
      StopAISpeech event,
      Emitter<ConversationState> emit,
      ) async {
    await _ttsService.stop();
  }

  Future<void> _onInterruptAI(
      InterruptAI event,
      Emitter<ConversationState> emit,
      ) async {
    await _ttsService.stop();

    final currentState = state;
    if (currentState is ConversationReady) {
      emit(currentState.copyWith(isAISpeaking: false));
    }
  }

  Future<void> _onStartSpeaking(
      StartSpeaking event,
      Emitter<ConversationState> emit,
      ) async {
    final currentState = state;
    if (currentState is ConversationReady) {
      emit(currentState.copyWith(
        isAISpeaking: true,
        ttsState: TTSState.speaking,
      ));
    }
  }

  Future<void> _onStopSpeaking(
      StopSpeaking event,
      Emitter<ConversationState> emit,
      ) async {
    final currentState = state;
    if (currentState is ConversationReady) {
      emit(currentState.copyWith(
        isAISpeaking: false,
        ttsState: TTSState.idle,
      ));
    }
  }

  Future<void> _onResetConversation(
      ResetConversation event,
      Emitter<ConversationState> emit,
      ) async {
    String currentScenario = 'general';
    if (state is ConversationReady) {
      currentScenario = (state as ConversationReady).currentTopic;
    }

    _conversationHistory = '';
    _currentUserLevel = 'intermediate';
    _isProcessingResponse = false;
    _autoStopTimer?.cancel();

    await _ttsService.stop();

    String initialGreeting = _greeting;
    if (currentScenario != 'general') {
      initialGreeting = "Conversation reset. Let's restart our '$currentScenario' role-play!";
    }

    final greetingMessage = ConversationMessage(
      text: initialGreeting,
      isUser: false,
      timestamp: DateTime.now(),
    );

    emit(ConversationReady(
      messages: [greetingMessage],
      userLevel: _currentUserLevel,
      currentTopic: currentScenario,
    ));
  }

  Future<void> _onUpdateUserLevel(
      UpdateUserLevel event,
      Emitter<ConversationState> emit,
      ) async {
    _currentUserLevel = event.level;

    final currentState = state;
    if (currentState is ConversationReady) {
      emit(currentState.copyWith(userLevel: event.level));
    }
  }

  Future<void> _onServiceError(
      _ServiceError event,
      Emitter<ConversationState> emit,
      ) async {
    emit(ConversationError(event.message));
  }

  void _assessAndUpdateLevel(String text) {
    _geminiService.assessUserLevel(text).then((level) {
      if (level != _currentUserLevel) {
        add(UpdateUserLevel(level));
      }
    }).catchError((e) {
      // Non-fatal
    });
  }

  @override
  Future<void> close() async {
    _autoStopTimer?.cancel();
    await _speechStateSub.cancel();
    await _speechResultSub.cancel();
    await _speechErrorSub.cancel();
    await _ttsStateSub.cancel();
    await _ttsErrorSub.cancel();
    _speechService.dispose();
    _ttsService.dispose();
    return super.close();
  }
}
