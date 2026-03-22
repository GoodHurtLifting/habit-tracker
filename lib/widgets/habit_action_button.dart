import 'package:flutter/material.dart';

import '../app_theme.dart';

enum HabitActionButtonVariant { primary, secondary }

class HabitActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final HabitActionButtonVariant variant;
  final bool isFullWidth;
  final Color? accentColor;

  const HabitActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HabitActionButtonVariant.primary,
    this.isFullWidth = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedAccent = accentColor ?? Theme.of(context).colorScheme.primary;

    final ButtonStyle baseStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      disabledBackgroundColor: AppTheme.disabled,
      disabledForegroundColor: AppTheme.metaText,
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
            foregroundColor: resolvedAccent,
            disabledForegroundColor: AppTheme.metaText,
            side: BorderSide(color: resolvedAccent),
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
