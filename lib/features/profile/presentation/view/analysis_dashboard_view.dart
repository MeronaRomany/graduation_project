import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';
import 'package:graduation_app/features/profile/presentation/cubit/analysis_dashboard_cubit.dart';
import 'package:graduation_app/models/learning_session_model.dart';
import 'package:graduation_app/services/firestore_service.dart';
import 'widgets/skill_comparison_card.dart';
import 'widgets/score_trend_chart.dart';

class AnalysisDashboardView extends StatelessWidget {
  static const String routeName = '/analysis-dashboard';
  final String userId;

  const AnalysisDashboardView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalysisDashboardCubit(FireStoreService())..loadAnalytics(userId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Learning Analysis'),
          actions: [
            BlocBuilder<AnalysisDashboardCubit, AnalysisDashboardState>(
              builder: (context, state) {
                return PopupMenuButton<AnalysisFilter>(
                  onSelected: (filter) => context.read<AnalysisDashboardCubit>().setFilter(filter),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: AnalysisFilter.last7Days, child: Text('Last 7 Days')),
                    const PopupMenuItem(value: AnalysisFilter.last30Days, child: Text('Last 30 Days')),
                    const PopupMenuItem(value: AnalysisFilter.last3Months, child: Text('Last 3 Months')),
                    const PopupMenuItem(value: AnalysisFilter.allTime, child: Text('All Time')),
                  ],
                  icon: const Icon(Icons.filter_list),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AnalysisDashboardCubit, AnalysisDashboardState>(
          builder: (context, state) {
            if (state.isLoading) return const Center(child: CircularProgressIndicator());
            if (state.error != null) return Center(child: Text(state.error!));
            if (state.sessions.isEmpty) return const Center(child: Text('No data available yet. Start practicing!'));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCards(state),
                  const SizedBox(height: 24),
                  SkillComparisonCard(
                    speakingAvg: state.avgSpeakingScore,
                    writingAvg: state.avgWritingScore,
                  ),
                  const SizedBox(height: 24),
                  Text('Score Trends', style: AppTextStyles.bold19),
                  const SizedBox(height: 16),
                  ScoreTrendChart(sessions: state.filteredSessions),
                  const SizedBox(height: 24),
                  _buildInsightsSection(context, state),
                  const SizedBox(height: 24),
                  _buildSkillBreakdown(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewCards(AnalysisDashboardState state) {
    final sessions = state.filteredSessions;
    final avgScore = sessions.isEmpty ? 0 : sessions.map((e) => e.overallScore).reduce((a, b) => a + b) / sessions.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Sessions',
            '${sessions.length}',
            Icons.history,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg. Score',
            '${avgScore.toInt()}%',
            Icons.analytics,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.bold25.copyWith(color: color)),
          Text(title, style: AppTextStyles.regular11),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context, AnalysisDashboardState state) {
    final insights = context.read<AnalysisDashboardCubit>().generateInsights();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber),
              const SizedBox(width: 8),
              Text('AI Insights', style: AppTextStyles.bold16),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(insight, style: AppTextStyles.regular13)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSkillBreakdown(AnalysisDashboardState state) {
    final sessions = state.filteredSessions;
    if (sessions.isEmpty) return const SizedBox.shrink();

    final grammar = sessions.map((e) => e.grammarScore).reduce((a, b) => a + b) / sessions.length;
    final vocab = sessions.map((e) => e.vocabularyScore).reduce((a, b) => a + b) / sessions.length;
    final fluency = sessions.map((e) => e.fluencyScore).reduce((a, b) => a + b) / sessions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skill Breakdown', style: AppTextStyles.bold19),
        const SizedBox(height: 16),
        _buildProgressBar('Grammar', grammar / 100, Colors.purple),
        const SizedBox(height: 12),
        _buildProgressBar('Vocabulary', vocab / 100, Colors.orange),
        const SizedBox(height: 12),
        _buildProgressBar('Fluency', fluency / 100, Colors.teal),
      ],
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.medium15),
            Text('${(progress * 100).toInt()}%', style: AppTextStyles.bold13.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }
}
