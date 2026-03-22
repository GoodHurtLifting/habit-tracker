import 'package:flutter/material.dart';

import '../app_theme.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool compact;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionPressed,
    this.compact = false,
  }) : assert(
          (actionLabel == null && onActionPressed == null) ||
              (actionLabel != null && onActionPressed != null),
          'actionLabel and onActionPressed must be provided together.',
        );

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: onActionPressed,
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: content,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: content,
      ),
    );
  }
}
