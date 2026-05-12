import 'package:flutter/material.dart';
import 'package:graduation_app/features/home/data/role_play_scenarios.dart';
import 'package:graduation_app/route_management/app_router.dart';
import 'role_play_card.dart';

class RolePlayGridView extends StatelessWidget {
  const RolePlayGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a Scenario',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Practice real-life conversations with AI',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: rolePlayScenarios.length,
          itemBuilder: (context, index) {
            final scenario = rolePlayScenarios[index];
            return RolePlayCard(
              scenario: scenario,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.aiSpeaker,
                  arguments: scenario,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
