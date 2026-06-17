import 'package:flutter/material.dart';

import 'package:graduation_app/core/utils/app_text_styles.dart';

class SkillComparisonCard extends StatelessWidget {
  final double speakingAvg;
  final double writingAvg;

  const SkillComparisonCard({
    super.key,
    required this.speakingAvg,
    required this.writingAvg,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skill Comparison', style: AppTextStyles.bold16),
            const SizedBox(height: 20),
            _buildComparisonRow(
              'Speaking',
              speakingAvg,
              Colors.blue,
              Icons.mic_none,
            ),
            const SizedBox(height: 20),
            _buildComparisonRow(
              'Writing',
              writingAvg,
              Colors.purple,
              Icons.edit_note,
            ),
            const SizedBox(height: 24),
            _buildInsightText(),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, double score, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.medium15),
            const Spacer(),
            Text('${score.toInt()}%', style: AppTextStyles.bold16.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 10,
        ),
      ],
    );
  }

  Widget _buildInsightText() {
    String insight;
    if (speakingAvg == 0 && writingAvg == 0) {
      insight = "Complete sessions to compare your skills!";
    } else if (writingAvg > speakingAvg + 5) {
      insight = "Your writing skills are stronger than your speaking skills. Practice more conversations!";
    } else if (speakingAvg > writingAvg + 5) {
      insight = "Your speaking skills are stronger than your writing skills. Try more writing exercises!";
    } else {
      insight = "Your skills are well-balanced. Keep up the good work!";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates, size: 18, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight,
              style: AppTextStyles.regular13.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
