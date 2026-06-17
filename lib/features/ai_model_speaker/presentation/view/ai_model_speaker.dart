import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/conversation_bloc.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../features/home/data/models/role_play_scenario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/session_evaluation_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../features/profile/presentation/view/my_progress_view.dart';
import '../../../../core/theme/colors_manager.dart';

class AIModelSpeakerScreen extends StatelessWidget {
  final RolePlayScenario? scenario;

  const AIModelSpeakerScreen({super.key, this.scenario});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationBloc(
        GeminiService(),
        context.read<SpeechService>(),
        context.read<TTSService>(),
      )..add(InitializeConversation(
        scenarioName: scenario?.id ?? 'general',
      )),
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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
              Color(0xFFE8F4FD),
              Color(0xFFF0E6FF),
              Color(0xFFFFF0F5),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<ConversationBloc, ConversationState>(
            listener: (context, state) {
              if (state is ConversationError) {
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
                      onPressed: () => bloc.add(ResetConversation()),
                    ),
                  ),
                );
              }

              if (state is ConversationReady) {
                _scrollToBottom();
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: BackgroundPatternPainter()),
                  ),
                  Column(
                    children: [
                      _buildHeader(),
                      IntrinsicHeight(child: _buildProfileSection()),
                      Expanded(child: _buildConversationArea(state)),
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
            onPressed: () =>
                context.read<ConversationBloc>().add(ResetConversation()),
            icon: const Icon(Icons.refresh, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    final scenario = widget.scenario;
    final gradientColors = scenario != null
        ? [
      scenario.categoryColor.withAlpha(204), // تعادل 0.8
      scenario.categoryColor,
    ]
        : const [Color(0xFF667eea), Color(0xFF764ba2)];
    final emoji = scenario?.emoji ?? '👤';
    final roleName = _getRoleName(scenario);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
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
                  color: (scenario?.categoryColor ?? Colors.purple).withAlpha(76),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 20),
          BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, state) {
              if (state is! ConversationReady) return const SizedBox.shrink();
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: state.isAISpeaking
                      ? const Color(0xFF4CAF50).withAlpha(25)
                      : Colors.white.withAlpha(178),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: state.isAISpeaking
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.withAlpha(76),
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
            },
          ),
        ],
      ),
    );
  }

  String _getRoleName(RolePlayScenario? scenario) {
    if (scenario == null) return 'AI Tutor';
    switch (scenario.id) {
      case 'restaurant': return 'Waiter/Waitress';
      case 'shopping': return 'Shop Assistant';
      case 'job_interview': return 'HR Manager';
      case 'hotel': return 'Receptionist';
      case 'airport': return 'Check-in Agent';
      case 'doctor': return 'Doctor';
      case 'making_friends': return 'Friendly Local';
      case 'coffee_shop': return 'Barista';
      case 'directions': return 'Local Guide';
      case 'business_meeting': return 'Colleague';
      case 'bank': return 'Bank Representative';
      case 'grocery': return 'Store Employee';
      default: return 'AI Tutor';
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
        child: state.messages.isEmpty
            ? const Center(
          child: Text(
            'Say something to start the conversation...',
            style: TextStyle(color: Colors.black38, fontSize: 14),
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            return _buildMessageBubble(state.messages[index], state);
          },
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(String errorMessage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
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
              style: TextStyle(fontSize: 14, color: Colors.red.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<ConversationBloc>().add(ResetConversation()),
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
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner': return Colors.green;
      case 'intermediate': return Colors.orange;
      case 'advanced': return Colors.red;
      default: return Colors.blue;
    }
  }

  Widget _buildMessageBubble(ConversationMessage message, ConversationReady state) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
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
                color: isUser ? const Color(0xFF667eea).withOpacity(0.9) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: isUser ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.3),
              ),
              child: const Icon(Icons.person_outline, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  // إغلاق وبناء جزء الـ Control Panel الذي تم قطعه سابقاً بشكل متناسق
  Widget _buildControlPanel(BuildContext context, ConversationState state) {
    if (state is ConversationError) return const SizedBox.shrink();

    final isListening = state is ConversationReady ? state.isListening : false;
    final bloc = context.read<ConversationBloc>();

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left placeholder to keep layout balanced
          const SizedBox(width: 48),

          // Center Mic button
          IconButton(
            icon: Icon(isListening ? Icons.stop : Icons.mic),
            iconSize: 40,
            color: isListening ? Colors.red : const Color(0xFF667eea),
            onPressed: () {
              if (isListening) {
                bloc.add(StopListening());
              } else {
                bloc.add(StartListening());
              }
            },
          ),

          // Right Evaluate Session button
          if (state is ConversationReady && state.messages.any((m) => m.isUser))
            IconButton(
              icon: const Icon(Icons.assignment_turned_in_outlined),
              iconSize: 32,
              color: Colors.green,
              tooltip: 'Evaluate Session',
              onPressed: () => _evaluateSession(context, state),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  void _evaluateSession(BuildContext context, ConversationReady state) async {
    final userMsgs = state.messages.where((m) => m.isUser).toList();
    if (userMsgs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please send some messages first to evaluate.')),
      );
      return;
    }

    // Stop speaking/listening before evaluation
    final bloc = context.read<ConversationBloc>();
    bloc.add(StopListening());
    bloc.add(StopAISpeech());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: ColorsManager.primary),
            SizedBox(height: 20),
            Text(
              'Analyzing your session...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Evaluating grammar, vocabulary, fluency, and pronunciation...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    try {
      final history = state.messages
          .map((m) => '${m.isUser ? "User" : "AI"}: ${m.text}')
          .join('\n');

      final geminiService = GeminiService();
      final evalMap = await geminiService.evaluateConversation(
        conversationHistory: history,
        topic: state.currentTopic,
      );

      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final evaluation = SessionEvaluation(
        id: '',
        userId: uid,
        grammarScore: evalMap['grammar_score'] ?? 70,
        vocabularyScore: evalMap['vocabulary_score'] ?? 70,
        fluencyScore: evalMap['fluency_score'] ?? 70,
        mistakesScore: evalMap['mistakes_score'] ?? 70,
        pronunciationScore: evalMap['pronunciation_score'] ?? 70,
        overallScore: evalMap['overall_score'] ?? 70,
        feedback: evalMap['feedback'] ?? '',
        timestamp: DateTime.now(),
        topic: state.currentTopic,
      );

      final firestoreService = FireStoreService();
      await firestoreService.saveSessionEvaluation(evaluation);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showEvaluationSummaryDialog(context, evaluation);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to evaluate session: $e')),
        );
      }
    }
  }

  void _showEvaluationSummaryDialog(BuildContext context, SessionEvaluation eval) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Center(
            child: Text(
              'Session Evaluation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: ColorsManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Overall Score',
                        style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${eval.overallScore}%',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDialogMetricRow('Grammar', eval.grammarScore, Colors.blue),
                _buildDialogMetricRow('Vocabulary', eval.vocabularyScore, Colors.orange),
                _buildDialogMetricRow('Fluency', eval.fluencyScore, Colors.purple),
                _buildDialogMetricRow('Pronunciation', eval.pronunciationScore, Colors.green),
                const Divider(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'AI Tutor Feedback:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  eval.feedback,
                  style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(); // Go back home
              },
              child: Text(
                'Close',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(); // Go back home
                Navigator.pushNamed(context, MyProgressView.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogMetricRow(String skill, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              skill,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100.0,
                color: color,
                backgroundColor: color.withOpacity(0.1),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$score%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
