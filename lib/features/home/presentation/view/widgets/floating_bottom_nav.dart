import 'package:flutter/material.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.004), blurRadius: 40)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.search, color: ColorsManager.primary),
          Icon(Icons.chat_bubble_outline, color: Colors.grey),
          Icon(Icons.video_call_outlined, color: Colors.grey),
          Icon(Icons.person_outline, color: Colors.grey),
        ],
      ),
    );
  }
}
