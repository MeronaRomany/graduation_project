import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CustomCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
    if (onTap == null) return card;
    return InkWell(onTap: onTap, child: card);
  }
}
