import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors_manager.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../home/data/models/role_play_scenario.dart';
import '../cubit/writing_practice_cubit.dart';
import '../cubit/writing_practice_state.dart';
import 'writing_analysis_screen.dart';

class WritingPracticeScreen extends StatefulWidget {
  static const String routeName = '/writing-practice';

  const WritingPracticeScreen({super.key});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  WritingPracticeLoaded? _lastLoadedState;

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
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('AI Writing Chat'),
          actions: [
            TextButton(
              onPressed: () => context.read<WritingPracticeCubit>().finishAndAnalyze(),
              child: const Text('Finish',
                  style: TextStyle(
                      color: ColorsManager.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: BlocConsumer<WritingPracticeCubit, WritingPracticeState>(
          listener: (context, state) {
            if (state is WritingPracticeLoaded) {
              _lastLoadedState = state;
              _scrollToBottom();
            } else if (state is WritingAnalysisSuccess) {
              final analysis = state.analysis;
              _chatController.clear();
              
              // التنقل للصفحة الجديدة أولاً لتجنب مشاكل الـ Context عند الـ Reset
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WritingAnalysisScreen(analysis: analysis),
                ),
              ).then((_) {
                // تصفير المحادثة عند العودة من صفحة التحليل
                if (context.mounted) {
                  context.read<WritingPracticeCubit>().reset();
                }
              });
            } else if (state is WritingPracticeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final displayState = state is WritingPracticeLoaded ? state : _lastLoadedState;
  
            if (displayState != null) {
              return Stack(
                children: [
                  _buildChatUI(context, displayState, isKeyboardVisible),
                  if (state is WritingPracticeLoading)
                    Container(
                      color: Colors.white.withOpacity(0.8),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: ColorsManager.primary),
                            SizedBox(height: 16),
                            Text('AI is analyzing your writing...', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: ColorsManager.primary)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }
  
            return const Center(child: CircularProgressIndicator(color: ColorsManager.primary));
          },
        ),
      ),
    );
  }

  Widget _buildChatUI(BuildContext context, WritingPracticeLoaded state, bool isKeyboardVisible) {
    return Column(
      children: [
        _buildScenarioSelector(context, state),
        Expanded(child: _buildChatList(state)),
        if (state.isSendingMessage)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('AI is typing...',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ),
        _buildInputArea(context, state, isKeyboardVisible),
      ],
    );
  }

  Widget _buildScenarioSelector(BuildContext context, WritingPracticeLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          const Text('Topic: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RolePlayScenario>(
                isExpanded: true,
                value: state.selectedScenario,
                items: state.scenarios.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text('${s.emoji} ${s.title}',
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (s) {
                  if (s != null) {
                    context.read<WritingPracticeCubit>().selectScenario(s);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(WritingPracticeLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return _buildChatBubble(message);
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? ColorsManager.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(
      BuildContext context, WritingPracticeLoaded state, bool isKeyboardVisible) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: isKeyboardVisible ? 16 : 100,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (val) => _handleSend(context),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: ColorsManager.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _handleSend(context),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend(BuildContext context) {
    if (_chatController.text.trim().isNotEmpty) {
      context.read<WritingPracticeCubit>().sendMessage(_chatController.text);
      _chatController.clear();
      _scrollToBottom();
    }
  }
}
