import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';

class IceBreakerWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const IceBreakerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(23),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
        gradient: LinearGradient(
          transform: GradientRotation(0.2),
          colors: [
            color.withAlpha(30),
            color.withAlpha(25),
            color.withAlpha(20),
            color.withAlpha(15),
            color.withAlpha(10),
            color.withAlpha(5),
            color.withAlpha(1),
            color.withAlpha(0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(title, style: AppTextStyles.semiBold16),
            subtitle: Text(subtitle, style: AppTextStyles.regular13),
          )
        ],
      ),
    );
  }
}
