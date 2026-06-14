import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';
import 'package:graduation_app/features/profile/presentation/cubit/progress_cubit.dart';
import 'package:graduation_app/features/profile/presentation/cubit/progress_state.dart';
import 'package:graduation_app/models/session_evaluation_model.dart';
import 'package:easy_localization/easy_localization.dart';

class MyProgressView extends StatefulWidget {
  static const String routeName = '/my-progress';
  const MyProgressView({super.key});

  @override
  State<MyProgressView> createState() => _MyProgressViewState();
}

class _MyProgressViewState extends State<MyProgressView> {
  String selectedMetric = 'overall'; // 'overall' | 'grammar' | 'vocabulary' | 'fluency' | 'pronunciation'

  @override
  Widget build(BuildContext context) {
    final primaryColor = ColorsManager.primary;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          'My Learning Progress',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          if (state is ProgressLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ColorsManager.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading your progress analytics...',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  )
                ],
              ),
            );
          }

          if (state is ProgressError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<ProgressCubit>().loadProgress(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProgressLoaded) {
            final filteredEvals = _filterEvaluations(state.evaluations, state.selectedTimeSpan);
            
            return RefreshIndicator(
              onRefresh: () => context.read<ProgressCubit>().loadProgress(),
              color: ColorsManager.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level card
                    _buildOverviewCard(state.averageScores['overall'] ?? 0.0),
                    const SizedBox(height: 24),

                    // Metrics Aggregates Grid
                    Text('Skill Breakdown', style: AppTextStyles.bold19.copyWith(color: Colors.black87)),
                    const SizedBox(height: 12),
                    _buildMetricsGrid(state.averageScores),
                    const SizedBox(height: 28),

                    // Graph Section Title & TimeSpan Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('Performance Over Time', style: AppTextStyles.bold19.copyWith(color: Colors.black87)),
                        ),
                        const SizedBox(width: 8),
                        _buildTimeSpanSelector(context, state.selectedTimeSpan),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Metric Chip Selector
                    _buildMetricSelectorChips(),
                    const SizedBox(height: 16),

                    // Chart
                    _buildChartCard(filteredEvals, primaryColor),
                    const SizedBox(height: 28),

                    // Insights Section
                    Text('💡 AI Learning Insights', style: AppTextStyles.bold19.copyWith(color: Colors.black87)),
                    const SizedBox(height: 12),
                    _buildInsightsList(state.insights),
                    const SizedBox(height: 28),

                    // Session by Session analysis
                    Text('Session History', style: AppTextStyles.bold19.copyWith(color: Colors.black87)),
                    const SizedBox(height: 12),
                    _buildSessionHistory(filteredEvals),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<SessionEvaluation> _filterEvaluations(List<SessionEvaluation> evals, String timeSpan) {
    final now = DateTime.now();
    if (timeSpan == 'days') {
      final cutoff = now.subtract(const Duration(days: 7));
      return evals.where((e) => e.timestamp.isAfter(cutoff)).toList();
    } else if (timeSpan == 'weeks') {
      final cutoff = now.subtract(const Duration(days: 28));
      return evals.where((e) => e.timestamp.isAfter(cutoff)).toList();
    } else if (timeSpan == 'months') {
      final cutoff = now.subtract(const Duration(days: 180));
      return evals.where((e) => e.timestamp.isAfter(cutoff)).toList();
    }
    return evals;
  }

  Widget _buildOverviewCard(double overallScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primary,
            ColorsManager.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Proficiency',
                  style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  '${overallScore.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  _getProficiencyStatus(overallScore),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }

  String _getProficiencyStatus(double score) {
    if (score >= 85) return 'Excellent Level - Advanced Speaker';
    if (score >= 70) return 'Very Good Level - Intermediate';
    if (score >= 50) return 'Good Start - Elementary Level';
    if (score > 0) return 'Beginner - Keep practicing!';
    return 'Complete a session to start tracking!';
  }

  Widget _buildMetricsGrid(Map<String, double> averages) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildMetricGridCard('Grammar', averages['grammar'] ?? 0.0, Colors.blue, Icons.g_translate_outlined),
        _buildMetricGridCard('Vocabulary', averages['vocabulary'] ?? 0.0, Colors.orange, Icons.menu_book_outlined),
        _buildMetricGridCard('Fluency', averages['fluency'] ?? 0.0, Colors.purple, Icons.speed_outlined),
        _buildMetricGridCard('Pronunciation', averages['pronunciation'] ?? 0.0, Colors.green, Icons.keyboard_voice_outlined),
      ],
    );
  }

  Widget _buildMetricGridCard(String label, double score, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${score.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                '%',
                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              color: color,
              backgroundColor: color.withOpacity(0.1),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSpanSelector(BuildContext context, String selectedSpan) {
    final options = {
      'days': 'Days',
      'weeks': 'Weeks',
      'months': 'Months',
      'all': 'All-Time',
    };

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.entries.map((entry) {
          final isSelected = selectedSpan == entry.key;
          return GestureDetector(
            onTap: () => context.read<ProgressCubit>().changeTimeSpan(entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? ColorsManager.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricSelectorChips() {
    final metrics = {
      'overall': 'Overall',
      'grammar': 'Grammar',
      'vocabulary': 'Vocab',
      'fluency': 'Fluency',
      'pronunciation': 'Pronunciation',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: metrics.entries.map((entry) {
          final isSelected = selectedMetric == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    selectedMetric = entry.key;
                  });
                }
              },
              selectedColor: ColorsManager.primary.withOpacity(0.2),
              checkmarkColor: ColorsManager.primary,
              labelStyle: TextStyle(
                color: isSelected ? ColorsManager.primary : Colors.black54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? ColorsManager.primary : Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartCard(List<SessionEvaluation> evals, Color primaryColor) {
    if (evals.isEmpty) {
      return Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: const Center(
          child: Text(
            'No session evaluations found for this period.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    final spots = _getSpots(evals, selectedMetric);
    final sorted = List<SessionEvaluation>.from(evals)..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (spots.length / 5).clamp(1.0, double.infinity),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < sorted.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(sorted[idx].timestamp),
                        style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: primaryColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: spots.length <= 15,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: primaryColor,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.3),
                    primaryColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<SessionEvaluation> evals, String metric) {
    if (evals.isEmpty) return [const FlSpot(0, 0)];
    final sorted = List<SessionEvaluation>.from(evals)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final eval = sorted[i];
      double val = 0.0;
      switch (metric) {
        case 'grammar': val = eval.grammarScore.toDouble(); break;
        case 'vocabulary': val = eval.vocabularyScore.toDouble(); break;
        case 'fluency': val = eval.fluencyScore.toDouble(); break;
        case 'pronunciation': val = eval.pronunciationScore.toDouble(); break;
        default: val = eval.overallScore.toDouble(); break;
      }
      spots.add(FlSpot(i.toDouble(), val));
    }
    if (spots.length == 1) {
      return [FlSpot(0, spots[0].y), FlSpot(1, spots[0].y)];
    }
    return spots;
  }

  Widget _buildInsightsList(List<String> insights) {
    return Column(
      children: insights.map((insight) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsManager.primary.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primary.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  insight,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionHistory(List<SessionEvaluation> evals) {
    if (evals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: const Center(
          child: Text(
            'Start a conversation session to see your progress history!',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: evals.length,
      itemBuilder: (context, index) {
        final eval = evals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.15)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: _getScoreColor(eval.overallScore).withOpacity(0.1),
              child: Text(
                _getEmoji(eval.topic),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              _formatTopic(eval.topic),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            subtitle: Text(
              DateFormat.yMMMd().format(eval.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(eval.overallScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${eval.overallScore}%',
                    style: TextStyle(
                      color: _getScoreColor(eval.overallScore),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            onTap: () => _showSessionDetails(context, eval),
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getEmoji(String topic) {
    switch (topic.toLowerCase()) {
      case 'restaurant': return '🍔';
      case 'shopping': return '🛍️';
      case 'job_interview': return '💼';
      case 'hotel': return '🏨';
      case 'airport': return '✈️';
      case 'doctor': return '🩺';
      case 'making_friends': return '🤝';
      case 'coffee_shop': return '☕';
      case 'directions': return '📍';
      case 'business_meeting': return '👔';
      case 'bank': return '🏦';
      case 'grocery': return '🛒';
      default: return '💬';
    }
  }

  String _formatTopic(String topic) {
    if (topic == 'general') return 'General English Practice';
    final parts = topic.split('_');
    return parts.map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
  }

  void _showSessionDetails(BuildContext context, SessionEvaluation eval) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        _getEmoji(eval.topic),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatTopic(eval.topic),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                            ),
                            Text(
                              DateFormat.yMMMd().add_jm().format(eval.timestamp),
                              style: TextStyle(color: Colors.grey[500], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getScoreColor(eval.overallScore).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${eval.overallScore}%',
                          style: TextStyle(
                            color: _getScoreColor(eval.overallScore),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Skills Scores',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildScoreRow('Grammar', eval.grammarScore, Colors.blue),
                  _buildScoreRow('Vocabulary', eval.vocabularyScore, Colors.orange),
                  _buildScoreRow('Fluency', eval.fluencyScore, Colors.purple),
                  _buildScoreRow('Mistakes Avoidance', eval.mistakesScore, Colors.redAccent),
                  _buildScoreRow('Pronunciation', eval.pronunciationScore, Colors.green),
                  const Divider(height: 32),
                  const Text(
                    'AI Feedback & Recommendations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      eval.feedback,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildScoreRow(String skill, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
              ),
              Text(
                '$score%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100.0,
              color: color,
              backgroundColor: color.withOpacity(0.1),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
