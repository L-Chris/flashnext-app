import 'package:flutter/material.dart';

class ReviewCardFrame extends StatelessWidget {
  const ReviewCardFrame({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: radius),
      // WebView and other opaque children must not cover the rounded border.
      foregroundDecoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.25,
        ),
        borderRadius: radius,
      ),
      child: child,
    );
  }
}
