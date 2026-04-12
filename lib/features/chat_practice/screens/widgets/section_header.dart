import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  const SectionHeader({super.key, required this.title, this.count});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          count != null
              ? Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: Color(0xFF00EFA0)),
                    const SizedBox(width: 5),
                    Text(
                      "$count active",
                      style: AppTextStyles.medium12.copyWith(
                        color: Color(0xff006944),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
