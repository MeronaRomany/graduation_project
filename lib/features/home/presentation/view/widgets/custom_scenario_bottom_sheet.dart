import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_colors.dart';
import 'package:graduation_app/features/home/data/models/role_play_scenario.dart';
import 'package:graduation_app/route_management/app_router.dart';

class CustomScenarioBottomSheet extends StatefulWidget {
  const CustomScenarioBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CustomScenarioBottomSheet(),
    );
  }

  @override
  State<CustomScenarioBottomSheet> createState() =>
      _CustomScenarioBottomSheetState();
}

class _CustomScenarioBottomSheetState extends State<CustomScenarioBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startScenario() {
    if (_controller.text.trim().isEmpty) return;

    final topic = _controller.text.trim();
    final scenario = RolePlayScenario(
      id: 'custom',
      title: topic,
      description: 'Custom scenario',
      emoji: '✨',
      systemPrompt:
          'You are a roleplay partner. The user wants to practice English about: $topic. '
              'Start a natural conversation about this topic. Greet the user and ask them '
              'a question related to $topic to begin the roleplay. Stay in character and '
              'help the user practice their English through this conversation.',
      starterMessage: '',
      difficulty: DifficultyLevel.intermediate,
      category: ScenarioCategory.dailyLife,
      cefrLevel: CefrLevel.b12,
    );

    Navigator.of(context).pop();
    Navigator.pushNamed(
      context,
      AppRouter.aiSpeaker,
      arguments: scenario,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Custom Scenario',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What would you like to practice?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText:
                    'e.g. Ordering food at a restaurant, job interview, asking for directions...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startScenario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 24),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
