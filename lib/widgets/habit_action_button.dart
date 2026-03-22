import 'package:flutter/material.dart';

enum HabitActionButtonVariant { primary, secondary }

class HabitActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final HabitActionButtonVariant variant;
  final bool isFullWidth;

  const HabitActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HabitActionButtonVariant.primary,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle baseStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    final Widget button = switch (variant) {
      HabitActionButtonVariant.primary => ElevatedButton(
          onPressed: onPressed,
          style: baseStyle,
          child: Text(label),
        ),
      HabitActionButtonVariant.secondary => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          child: Text(label),
        ),
    };

    if (!isFullWidth) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}
