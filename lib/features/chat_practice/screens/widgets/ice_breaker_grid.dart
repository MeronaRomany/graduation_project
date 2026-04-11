
import 'package:flutter/material.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/glass_card.dart';

class IcebreakerGrid extends StatelessWidget {
  const IcebreakerGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      gradientColor: Colors.blue,
      child: Text("Icebreaker Content"),
    );
  }
}
