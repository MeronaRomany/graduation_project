import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/role_play_prompts.dart';
import '../../../../features/home/data/models/role_play_scenario.dart';

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

class ReportError extends ConversationEvent {
  final String error;

  const ReportError(this.error);

  @override
  List<Object?> get props => [error];
}

class OpenAppSettings extends ConversationEvent {}

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
  final RolePlayScenario? scenario;

  Timer? _autoStopTimer;
  String _conversationHistory = '';
  String _currentUserLevel = 'intermediate';
  bool _isProcessingResponse = false;

  ConversationBloc(
    this._geminiService,
    this._speechService,
    this._ttsService, {
    this.scenario,
  }) : super(ConversationInitial()) {
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
    on<ReportError>(_onReportError);
    on<OpenAppSettings>(_onOpenAppSettings);

    // Listen to speech service streams
    _speechService.state.listen(
      (state) {
        if (state == SpeechState.completed) {
          // Auto-send recognized speech
          add(StopListening());
        }
      },
      onError: (error) {
        print('[RolePlay ERROR] Speech state stream error: $error');
        add(ReportError('Speech service error: $error'));
      },
    );

    _speechService.result.listen(
      (text) {
        print('[RolePlay] Speech result received: "$text"');
        add(SpeechRecognized(text));
      },
      onError: (error) {
        print('[RolePlay ERROR] Speech result stream error: $error');
        add(ReportError('Speech recognition error: $error'));
      },
    );

    _speechService.error.listen(
      (error) {
        print('[RolePlay ERROR] Speech service reported error: $error');
        add(ReportError(error));
      },
      onError: (error) {
        print('[RolePlay ERROR] Speech error stream error: $error');
      },
    );

    // Listen for open settings requests (e.g., when permission permanently denied)
    _speechService.openSettings.listen(
      (_) {
        print('[RolePlay] Opening app settings for microphone permission');
        add(OpenAppSettings());
      },
      onError: (error) {
        print('[RolePlay ERROR] Open settings stream error: $error');
      },
    );

    // Listen to TTS service streams
    _ttsService.state.listen(
      (state) {
        // Update state through events instead of direct emit
        if (state == TTSState.speaking) {
          add(StartSpeaking());
        } else if (state == TTSState.idle) {
          add(StopSpeaking());
        }
      },
      onError: (error) {
        print('[RolePlay ERROR] TTS state stream error: $error');
        add(ReportError('TTS service error: $error'));
      },
    );

    _ttsService.error.listen(
      (error) {
        print('[RolePlay ERROR] TTS service reported error: $error');
        add(ReportError(error));
      },
      onError: (error) {
        print('[RolePlay ERROR] TTS error stream error: $error');
      },
    );
  }

  Future<void> _onInitializeConversation(
    InitializeConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());

    try {
      print('[RolePlay] Initializing conversation services...');
      
      // Initialize services with individual error handling
      bool speechInitialized = false;
      bool ttsInitialized = false;
      
      try {
        speechInitialized = await _speechService.initialize();
        print('[RolePlay] Speech service initialized: $speechInitialized');
      } catch (e, stackTrace) {
        print('[RolePlay ERROR] Speech service initialization failed: $e');
        print('[RolePlay ERROR] Stack trace: $stackTrace');
      }
      
      try {
        ttsInitialized = await _ttsService.initialize();
        print('[RolePlay] TTS service initialized: $ttsInitialized');
      } catch (e, stackTrace) {
        print('[RolePlay ERROR] TTS service initialization failed: $e');
        print('[RolePlay ERROR] Stack trace: $stackTrace');
      }

      if (!speechInitialized || !ttsInitialized) {
        final errorMsg = 'Failed to initialize services: Speech=$speechInitialized, TTS=$ttsInitialized';
        print('[RolePlay ERROR] $errorMsg');
        emit(ConversationError(errorMsg));
        return;
      }

      // Start with a greeting message (scenario-specific or default)
      final greetingText = scenario != null
          ? RolePlayPrompts.getInitialGreeting(scenario!, _currentUserLevel)
          : "Hello! I'm your English practice partner. I'm excited to help you improve your English skills. What would you like to talk about today?";
      final initialMessage = ConversationMessage(
        text: greetingText,
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
      try {
        print('[RolePlay] Starting to listen...');
        await _speechService.startListening();
        emit(currentState.copyWith(isListening: true));
        print('[RolePlay] Listening started successfully');

        // Auto-stop after 10 seconds of listening
        _autoStopTimer?.cancel();
        _autoStopTimer = Timer(const Duration(seconds: 10), () {
          add(StopListening());
        });
      } catch (e, stackTrace) {
        print('[RolePlay ERROR] Failed to start listening: $e');
        print('[RolePlay ERROR] Stack trace: $stackTrace');
        emit(ConversationError('Failed to start listening: $e'));
      }
    }
  }

  Future<void> _onStopListening(
    StopListening event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      _autoStopTimer?.cancel();
      await _speechService.stopListening();
      print('[RolePlay] Stopped listening');

      final currentState = state;
      if (currentState is ConversationReady) {
        emit(currentState.copyWith(isListening: false));
      }
    } catch (e, stackTrace) {
      print('[RolePlay ERROR] Failed to stop listening: $e');
      print('[RolePlay ERROR] Stack trace: $stackTrace');
      
      final currentState = state;
      if (currentState is ConversationReady) {
        emit(currentState.copyWith(isListening: false));
      }
    }
  }

  Future<void> _onSpeechRecognized(
    SpeechRecognized event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      print('[RolePlay] Speech recognized: "${event.text}"');
      
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
        String assessedLevel = _currentUserLevel;
        try {
          assessedLevel = await _assessUserLevel(event.text);
          print('[RolePlay] User level assessed as: $assessedLevel');
        } catch (e, stackTrace) {
          print('[RolePlay ERROR] Failed to assess user level: $e');
          print('[RolePlay ERROR] Stack trace: $stackTrace');
        }
        
        if (assessedLevel != _currentUserLevel) {
          _currentUserLevel = assessedLevel;
          add(UpdateUserLevel(assessedLevel));
        }

        // Send message to AI
        add(SendMessage(event.text));
      }
    } catch (e, stackTrace) {
      print('[RolePlay ERROR] Error processing speech recognition: $e');
      print('[RolePlay ERROR] Stack trace: $stackTrace');
      emit(ConversationError('Error processing speech: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    if (_isProcessingResponse) {
      print('[RolePlay] Message processing already in progress, skipping...');
      return;
    }

    _isProcessingResponse = true;
    print('[RolePlay] Sending message to AI...');

    try {
      final currentState = state;
      if (currentState is ConversationReady) {
        // Update conversation history
        _conversationHistory += '\nUser: ${event.message}';

        // Get AI response with detailed error handling
        String aiResponse;
        try {
          print('[RolePlay] Calling GeminiService with scenario: ${scenario?.title ?? "None"}');
          aiResponse = await _geminiService.generateResponse(
            userMessage: event.message,
            conversationHistory: _conversationHistory,
            userLevel: _currentUserLevel,
            scenario: scenario,
          );
          print('[RolePlay] AI response received: ${aiResponse.substring(0, aiResponse.length > 50 ? 50 : aiResponse.length)}...');
        } catch (e, stackTrace) {
          print('[RolePlay ERROR] GeminiService failed: $e');
          print('[RolePlay ERROR] Stack trace: $stackTrace');
          throw Exception('AI service error: $e');
        }

        _conversationHistory += '\nAI: $aiResponse';

        // Add AI message
        final aiMessage = ConversationMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );

        final updatedMessages = [...currentState.messages, aiMessage];
        emit(currentState.copyWith(messages: updatedMessages));
        print('[RolePlay] AI message added to conversation');

        // Speak the AI response
        add(SpeakAIResponse(aiResponse));
      }
    } catch (e, stackTrace) {
      print('[RolePlay ERROR] Failed to send message: $e');
      print('[RolePlay ERROR] Stack trace: $stackTrace');
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
    try {
      print('[RolePlay] Speaking AI response...');
      await _ttsService.speak(event.text);
      print('[RolePlay] TTS completed');
    } catch (e, stackTrace) {
      print('[RolePlay ERROR] TTS failed: $e');
      print('[RolePlay ERROR] Stack trace: $stackTrace');
      emit(ConversationError('Failed to speak response: $e'));
    }
  }

  Future<void> _onStopAISpeech(
    StopAISpeech event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _ttsService.stop();
      print('[RolePlay] AI speech stopped');
    } catch (e, stackTrace) {
      print('[RolePlay ERROR] Failed to stop speech: $e');
      print('[RolePlay ERROR] Stack trace: $stackTrace');
    }
  }

  Future<void> _onInterruptAI(
    InterruptAI event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _ttsService.stop();
      print('[RolePlay] AI interrupted');
    } catch (e, stackTrace) {
      print('[RolePlay ERROR] Failed to interrupt AI: $e');
      print('[RolePlay ERROR] Stack trace: $stackTrace');
    }

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
      print('[RolePlay] Assessing user level...');
      final level = await _geminiService.assessUserLevel(text);
      print('[RolePlay] Assessment complete: $level');
      return level;
    } catch (e, stackTrace) {
      print('[RolePlay ERROR] Error assessing user level: $e');
      print('[RolePlay ERROR] Stack trace: $stackTrace');
      return 'intermediate';
    }
  }

  Future<void> _onReportError(
    ReportError event,
    Emitter<ConversationState> emit,
  ) async {
    print('[RolePlay ERROR] Reported error: ${event.error}');
    emit(ConversationError(event.error));
  }

  Future<void> _onOpenAppSettings(
    OpenAppSettings event,
    Emitter<ConversationState> emit,
  ) async {
    print('[RolePlay] Opening device app settings');
    await openAppSettings();
  }

  @override
  Future<void> close() {
    _autoStopTimer?.cancel();
    _speechService.dispose();
    _ttsService.dispose();
    return super.close();
  }
}
