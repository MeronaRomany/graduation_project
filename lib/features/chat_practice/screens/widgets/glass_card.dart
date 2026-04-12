import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? gradientColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 45,
    this.gradientColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(135),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withAlpha(5), width: 0.5),
              gradient: gradientColor != null
                  ? LinearGradient(
                      colors: [gradientColor!.withAlpha(2), Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
