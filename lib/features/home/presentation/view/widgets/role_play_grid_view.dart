import 'package:flutter/material.dart';
import 'package:graduation_app/features/home/data/role_play_scenarios.dart';
import 'package:graduation_app/features/home/data/models/role_play_scenario.dart';
import 'package:graduation_app/route_management/app_router.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/custom_scenario_bottom_sheet.dart';
import 'role_play_card.dart';

class RolePlayGridView extends StatelessWidget {
  const RolePlayGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final availableLevels = CefrLevel.values
        .where((level) => RolePlayScenario.getByCefrLevel(rolePlayScenarios, level).isNotEmpty)
        .toList();

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
        GestureDetector(
          onTap: () => CustomScenarioBottomSheet.show(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6200EE),
                  Color(0xFF9C27B0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6200EE).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '✨',
                    style: TextStyle(fontSize: 36),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom Scenario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Practice any topic you want',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...availableLevels.map((level) {
          final levelScenarios = RolePlayScenario.getByCefrLevel(rolePlayScenarios, level);
          return _buildLevelSection(context, level, levelScenarios);
        }),
      ],
    );
  }

  Widget _buildLevelSection(
      BuildContext context, CefrLevel level, List<RolePlayScenario> scenarios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scenarios.first.cefrColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scenarios.first.cefrColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scenarios.first.cefrColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scenarios.first.cefrLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLevelTitle(level),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scenarios.first.cefrColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scenarios.first.cefrDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${scenarios.length} scenarios',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: scenarios.length,
          itemBuilder: (context, index) {
            final scenario = scenarios[index];
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
        const SizedBox(height: 24),
      ],
    );
  }

  String _getLevelTitle(CefrLevel level) {
    switch (level) {
      case CefrLevel.a11:
        return 'Absolute Beginner';
      case CefrLevel.a12:
        return 'Beginner';
      case CefrLevel.a21:
        return 'Elementary';
      case CefrLevel.a22:
        return 'Elementary+';
      case CefrLevel.b11:
        return 'Pre-intermediate';
      case CefrLevel.b12:
        return 'Intermediate';
      case CefrLevel.b21:
        return 'Upper-intermediate';
      case CefrLevel.b22:
        return 'Upper-intermediate+';
    }
  }
}
