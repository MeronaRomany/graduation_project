import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';

// Events
abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeConversation extends ConversationEvent {}

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

class UpdateUserLevel extends ConversationEvent {
  final String level;

  const UpdateUserLevel(this.level);

  @override
  List<Object?> get props => [level];
}

// States
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

class ConversationMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? level; // For user level assessment

  const ConversationMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.level,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp, level];
}

// BLoC
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GeminiService _geminiService;
  final SpeechService _speechService;
  final TTSService _ttsService;

  Timer? _autoStopTimer;
  String _conversationHistory = '';
  String _currentUserLevel = 'intermediate';
  bool _isProcessingResponse = false;

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

    // Listen to speech service streams
    _speechService.state.listen((state) {
      if (state == SpeechState.completed) {
        // Auto-send recognized speech
        add(StopListening());
      }
    });

    _speechService.result.listen((text) {
      add(SpeechRecognized(text));
    });

    _speechService.error.listen((error) {
      add(ConversationError(error) as ConversationEvent);
    });

    // Listen to TTS service streams
    _ttsService.state.listen((state) {
      // Update state through events instead of direct emit
      if (state == TTSState.speaking) {
        add(StartSpeaking());
      } else if (state == TTSState.idle) {
        add(StopSpeaking());
      }
    });

    _ttsService.error.listen((error) {
      add(ConversationError(error) as ConversationEvent);
    });
  }

  Future<void> _onInitializeConversation(
    InitializeConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());

    try {
      // Initialize services
      final speechInitialized = await _speechService.initialize();
      final ttsInitialized = await _ttsService.initialize();

      if (!speechInitialized || !ttsInitialized) {
        emit(const ConversationError('Failed to initialize services'));
        return;
      }

      // Start with a greeting message
      final initialMessage = ConversationMessage(
        text:
            "Hello! I'm your English practice partner. I'm excited to help you improve your English skills. What would you like to talk about today?",
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(ConversationReady(
        messages: [initialMessage],
        userLevel: _currentUserLevel,
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
    if (currentState is ConversationReady) {
      await _speechService.startListening();
      emit(currentState.copyWith(isListening: true));

      // Auto-stop after 10 seconds of listening
      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(const Duration(seconds: 10), () {
        add(StopListening());
      });
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
      emit(currentState.copyWith(isListening: false));
    }
  }

  Future<void> _onSpeechRecognized(
    SpeechRecognized event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationReady) {
      // Add user message
      final userMessage = ConversationMessage(
        text: event.text,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...currentState.messages, userMessage];
      emit(currentState.copyWith(messages: updatedMessages));

      // Assess user level from the message
      final assessedLevel = await _assessUserLevel(event.text);
      if (assessedLevel != _currentUserLevel) {
        _currentUserLevel = assessedLevel;
        add(UpdateUserLevel(assessedLevel));
      }

      // Send message to AI
      add(SendMessage(event.text));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    if (_isProcessingResponse) return;

    _isProcessingResponse = true;

    try {
      final currentState = state;
      if (currentState is ConversationReady) {
        // Update conversation history
        _conversationHistory += '\nUser: ${event.message}';

        // Get AI response
        final aiResponse = await _geminiService.generateResponse(
          userMessage: event.message,
          conversationHistory: _conversationHistory,
          userLevel: _currentUserLevel,
        );

        _conversationHistory += '\nAI: $aiResponse';

        // Add AI message
        final aiMessage = ConversationMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );

        final updatedMessages = [...currentState.messages, aiMessage];
        emit(currentState.copyWith(messages: updatedMessages));

        // Speak the AI response
        add(SpeakAIResponse(aiResponse));
      }
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
    if (currentState is ConversationReady) {
      final aiMessage = ConversationMessage(
        text: event.response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...currentState.messages, aiMessage];
      emit(currentState.copyWith(messages: updatedMessages));
    }
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
      emit(currentState.copyWith(isAISpeaking: true));
    }
  }

  Future<void> _onStopSpeaking(
    StopSpeaking event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationReady) {
      emit(currentState.copyWith(isAISpeaking: false));
    }
  }

  Future<void> _onResetConversation(
    ResetConversation event,
    Emitter<ConversationState> emit,
  ) async {
    _conversationHistory = '';
    _currentUserLevel = 'intermediate';

    await _ttsService.stop();

    final greetingMessage = ConversationMessage(
      text:
          "Hello! I'm your English practice partner. I'm excited to help you improve your English skills. What would you like to talk about today?",
      isUser: false,
      timestamp: DateTime.now(),
    );

    emit(ConversationReady(
      messages: [greetingMessage],
      userLevel: _currentUserLevel,
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

  Future<String> _assessUserLevel(String text) async {
    try {
      return await _geminiService.assessUserLevel(text);
    } catch (e) {
      print('Error assessing user level: $e');
      return 'intermediate';
    }
  }

  @override
  Future<void> close() {
    _autoStopTimer?.cancel();
    _speechService.dispose();
    _ttsService.dispose();
    return super.close();
  }
}
