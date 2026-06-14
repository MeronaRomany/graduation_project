import 'package:flutter/material.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';

class HelpSupportView extends StatelessWidget {
  static const String routeName = '/help-support';
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Frequently Asked Questions', style: AppTextStyles.bold19),
          const SizedBox(height: 16),
          _buildFAQItem(
            question: 'How does the AI conversation work?',
            answer:
                'Fluentify uses Google Gemini AI to create realistic English conversation scenarios. You can practice role-play situations, daily conversations, and more with an AI partner that adapts to your level.',
          ),
          _buildFAQItem(
            question: 'How do I improve my level?',
            answer:
                'Practice regularly! Use AI conversations, join peer practice calls, and try different scenarios. Your level is assessed based on your performance and engagement.',
          ),
          _buildFAQItem(
            question: 'What is the peer practice feature?',
            answer:
                'Peer practice connects you with other learners for real-time audio conversations. You can practice English with a partner at a similar level.',
          ),
          _buildFAQItem(
            question: 'How do I change my English level?',
            answer:
                'Your level is automatically assessed based on your conversation performance. You can also practice at different CEFR levels (A1-B2) in the role-play section.',
          ),
          _buildFAQItem(
            question: 'Is my data secure?',
            answer:
                'Yes! We use Firebase Authentication and Firestore with security rules. Your conversations are not stored permanently, and your personal data is encrypted.',
          ),
          const SizedBox(height: 32),
          Text('Contact Us', style: AppTextStyles.bold19),
          const SizedBox(height: 16),
          _buildContactTile(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@fluentify.app',
            onTap: () {},
          ),
          _buildContactTile(
            icon: Icons.star_outline,
            title: 'Rate the App',
            subtitle: 'Help us improve with your feedback',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Fluentify v1.0.0',
              style: AppTextStyles.regular13.copyWith(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedBackgroundColor: Colors.grey[50],
        backgroundColor: Colors.grey[50],
        title: Text(
          question,
          style: AppTextStyles.medium15,
        ),
        iconColor: ColorsManager.primary,
        collapsedIconColor: Colors.grey,
        children: [
          Text(
            answer,
            style: AppTextStyles.regular13.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: ColorsManager.primary),
        title: Text(title, style: AppTextStyles.medium15),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.regular13.copyWith(color: Colors.grey[500]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }
}
