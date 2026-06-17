import 'package:flutter/material.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/test_component.dart';
import 'package:graduation_app/route_management/app_router.dart';

class TestsGridView extends StatelessWidget {
  const TestsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'text': 'Practice with AI',
        'icon': Icons.psychology_outlined,
        'color': const Color(0xFF667eea),
        'onTap': () => Navigator.pushNamed(context, AppRouter.aiSpeaker),
        'isSoon': false,
      },
      {
        'text': 'AI Writing Practice',
        'icon': Icons.edit_note,
        'color': const Color(0xFF9C27B0),
        'onTap': () => Navigator.pushNamed(context, AppRouter.writingPractice),
        'isSoon': false,
      },
      {
        'text': 'Chat with Friends',
        'icon': Icons.people_outline,
        'color': const Color(0xFF4CAF50),
        'onTap': null,
        'isSoon': false,
      },
      {
        'text': 'English Shadowing',
        'icon': Icons.auto_stories,
        'color': const Color(0xFFFF9800),
        'onTap': null,
        'isSoon': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Learning Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          itemCount: features.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final item = features[index];
            return TestComponent(
              text: item['text'],
              icon: item['icon'],
              color: item['color'],
              isSoon: item['isSoon'],
              onTap: item['onTap'],
            );
          },
        ),
      ],
    );
  }
}
