import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';
import 'package:graduation_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:graduation_app/features/profile/presentation/cubit/profile_state.dart';

class MyProgressView extends StatelessWidget {
  static const String routeName = '/my-progress';
  const MyProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLevelCard(user?.level ?? 'A1'),
                const SizedBox(height: 24),
                Text('Statistics', style: AppTextStyles.bold19),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.star_outline,
                        label: 'Current Level',
                        value: user?.level ?? 'A1',
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_today_outlined,
                        label: 'Member Since',
                        value: _getMemberSince(),
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.psychology_outlined,
                        label: 'AI Sessions',
                        value: '0',
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_outline,
                        label: 'Practice Calls',
                        value: '0',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('CEFR Level Guide', style: AppTextStyles.bold19),
                const SizedBox(height: 16),
                _buildLevelGuideItem('A1', 'Beginner', 'Basic phrases and expressions', Colors.green),
                _buildLevelGuideItem('A2', 'Elementary', 'Common everyday expressions', Colors.teal),
                _buildLevelGuideItem('B1', 'Intermediate', 'Deal with most travel situations', Colors.orange),
                _buildLevelGuideItem('B2', 'Upper Intermediate', 'Fluent & spontaneous interaction', Colors.red),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMemberSince() {
    final now = DateTime.now();
    return '${now.month}/${now.year}';
  }

  Widget _buildLevelCard(String level) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primary,
            ColorsManager.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Level $level',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getLevelDescription(level),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'A1':
        return 'Beginner - Keep going!';
      case 'A2':
        return 'Elementary - Great progress!';
      case 'B1':
        return 'Intermediate - Well done!';
      case 'B2':
        return 'Upper Intermediate - Excellent!';
      default:
        return 'Start your learning journey!';
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bold25.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.regular11.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGuideItem(
      String level, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              level,
              style: AppTextStyles.bold13.copyWith(color: color),
            ),
          ),
        ),
        title: Text(title, style: AppTextStyles.medium15),
        subtitle: Text(description,
            style: AppTextStyles.regular13.copyWith(color: Colors.grey[500])),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
