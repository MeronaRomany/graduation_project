import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';
import 'package:graduation_app/models/learning_session_model.dart';
import 'package:intl/intl.dart';

class ScoreTrendChart extends StatelessWidget {
  final List<LearningSession> sessions;

  const ScoreTrendChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    // Sort sessions by date for the chart
    final sortedSessions = List<LearningSession>.from(sessions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Limit to last 10 sessions for readability or based on filter
    final displaySessions = sortedSessions.length > 10 
        ? sortedSessions.sublist(sortedSessions.length - 10) 
        : sortedSessions;

    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < displaySessions.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(displaySessions[index].date),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
                reservedSize: 30,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: displaySessions.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.overallScore.toDouble());
              }).toList(),
              isCurved: true,
              color: ColorsManager.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: ColorsManager.primary.withOpacity(0.1),
              ),
            ),
          ],
          minY: 0,
          maxY: 100,
        ),
      ),
    );
  }
}
