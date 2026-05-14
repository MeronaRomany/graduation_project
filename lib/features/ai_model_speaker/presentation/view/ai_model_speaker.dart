import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/conversation_bloc.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../features/home/data/models/role_play_scenario.dart';

class AIModelSpeakerScreen extends StatelessWidget {
  final RolePlayScenario? scenario;

  const AIModelSpeakerScreen({super.key, this.scenario});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationBloc(
        GeminiService(),
        SpeechService(),
        TTSService(),
        scenario: scenario,
      )..add(InitializeConversation()),
      child: AIModelSpeakerView(scenario: scenario),
    );
  }
}

class AIModelSpeakerView extends StatefulWidget {
  final RolePlayScenario? scenario;

  const AIModelSpeakerView({super.key, this.scenario});

  @override
  State<AIModelSpeakerView> createState() => _AIModelSpeakerViewState();
}

class _AIModelSpeakerViewState extends State<AIModelSpeakerView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the listening indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Wave animation for the AI response indicator
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F4FD), // Light blue
              Color(0xFFF0E6FF), // Light purple
              Color(0xFFFFF0F5), // Lavender blush
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<ConversationBloc, ConversationState>(
            listener: (context, state) {
              if (state is ConversationError) {
                print('[AIModelSpeakerView] Error displayed: ${state.message}');
                // Capture bloc reference before showing SnackBar
                final bloc = context.read<ConversationBloc>();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red.shade700,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'RETRY',
                      textColor: Colors.white,
                      onPressed: () {
                        print('[AIModelSpeakerView] Retrying conversation initialization...');
                        bloc.add(ResetConversation());
                      },
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BackgroundPatternPainter(),
                    ),
                  ),

                  // Main content
                  Column(
                    children: [
                      // Header
                      _buildHeader(),

                      // Profile section
                      _buildProfileSection(),

                      // Conversation area
                      Expanded(
                        child: _buildConversationArea(state),
                      ),

                      // Control panel
                      _buildControlPanel(context, state),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final scenario = widget.scenario;
    final title = scenario?.title ?? 'Speak with AI';
    final subtitle = scenario != null ? 'Role-Play Mode' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: scenario?.categoryColor ?? Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<ConversationBloc>().add(ResetConversation());
            },
            icon: const Icon(Icons.refresh, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    final scenario = widget.scenario;
    final gradientColors = scenario != null
        ? [scenario.categoryColor.withAlpha(0.8 as int), scenario.categoryColor]
        : const [Color(0xFF667eea), Color(0xFF764ba2)];
    final emoji = scenario?.emoji ?? '👤';
    final roleName = _getRoleName(scenario);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // AI Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (scenario?.categoryColor ?? Colors.purple).withAlpha(0.3 as int),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // AI Status
          BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, state) {
              if (state is ConversationReady) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: state.isAISpeaking
                        ? const Color(0xFF4CAF50).withAlpha(0.1 as int)
                        : Colors.white.withAlpha(0.7 as int),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: state.isAISpeaking
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.withAlpha(0.3 as int),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isAISpeaking
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.isAISpeaking ? 'Speaking...' : roleName,
                        style: TextStyle(
                          color: state.isAISpeaking
                              ? const Color(0xFF4CAF50)
                              : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  String _getRoleName(RolePlayScenario? scenario) {
    if (scenario == null) return 'AI Tutor';
    switch (scenario.id) {
      case 'restaurant':
        return 'Waiter/Waitress';
      case 'shopping':
        return 'Shop Assistant';
      case 'job_interview':
        return 'HR Manager';
      case 'hotel':
        return 'Receptionist';
      case 'airport':
        return 'Check-in Agent';
      case 'doctor':
        return 'Doctor';
      case 'making_friends':
        return 'Friendly Local';
      case 'coffee_shop':
        return 'Barista';
      case 'directions':
        return 'Local Guide';
      case 'business_meeting':
        return 'Colleague';
      case 'bank':
        return 'Bank Representative';
      case 'grocery':
        return 'Store Employee';
      default:
        return 'AI Tutor';
    }
  }

  Widget _buildConversationArea(ConversationState state) {
    if (state is ConversationError) {
      return _buildErrorWidget(state.message);
    }
    
    if (state is ConversationReady) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            final message = state.messages[index];
            return _buildMessageBubble(message, state);
          },
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              print('[AIModelSpeakerView] Retry button pressed');
              context.read<ConversationBloc>().add(ResetConversation());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      ConversationMessage message, ConversationReady state) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI Avatar (small)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF667eea).withOpacity(0.9)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: isUser
                    ? null
                    : Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  if (message.level != null && isUser) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLevelColor(message.level!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Level: ${message.level}',
                        style: TextStyle(
                          color: _getLevelColor(message.level!),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            // User avatar placeholder
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.3),
              ),
              child: const Icon(Icons.person_outline,
                  size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context, ConversationState state) {
    // Don't show controls if there's an error
    if (state is ConversationError) {
      return const SizedBox.shrink();
    }
    
    if (state is ConversationReady) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Listening indicator
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 60,
                  height: 60,
                  transform: Matrix4.identity()..scale(_pulseAnimation.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: state.isListening
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.3),
                              Colors.grey.withOpacity(0.5)
                            ],
                          ),
                    boxShadow: state.isListening
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: IconButton(
                    onPressed: state.isListening
                        ? () => context
                            .read<ConversationBloc>()
                            .add(StopListening())
                        : () => context
                            .read<ConversationBloc>()
                            .add(StartListening()),
                    icon: Icon(
                      state.isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 20),

            // Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.isListening
                        ? 'Listening... Tap to stop'
                        : state.isAISpeaking
                            ? 'AI is speaking... Tap to interrupt'
                            : 'Tap to speak',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    state.isListening
                        ? 'Speak naturally in English'
                        : state.isAISpeaking
                            ? 'Tap the mic to interrupt AI'
                            : 'Press and hold to speak',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Interrupt button (shown when AI is speaking)
            if (state.isAISpeaking)
              Container(
                margin: const EdgeInsets.only(left: 16),
                child: IconButton(
                  onPressed: () =>
                      context.read<ConversationBloc>().add(InterruptAI()),
                  icon: const Icon(Icons.stop, color: Colors.red),
                  tooltip: 'Stop AI speech',
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.orange;
      case 'elementary':
        return Colors.blue;
      case 'intermediate':
        return Colors.green;
      case 'advanced':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// Background pattern painter for subtle visual interest
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw some subtle circles in the background
    for (int i = 0; i < 5; i++) {
      final center = Offset(
        size.width * (0.2 + i * 0.15),
        size.height * (0.1 + i * 0.2),
      );
      canvas.drawCircle(center, 100, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
