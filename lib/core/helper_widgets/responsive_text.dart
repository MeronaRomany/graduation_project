import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  const ResponsiveText({super.key, required this.child});
  final Text child;

  @override
  Widget build(BuildContext context) {
    return Flexible(child: FittedBox(child: child));
  }
}