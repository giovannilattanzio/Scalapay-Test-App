import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

/// Centered text with an optional action button, used for the initial, empty
/// and failure states of the catalog screen.
class CatalogMessage extends StatelessWidget {
  const CatalogMessage({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = actionLabel;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(t.spacing.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: t.typography.p3Medium.copyWith(
                color: t.colors.textSecondary,
              ),
            ),
            if (label != null) ...[
              SizedBox(height: t.spacing.s),
              ScalapayButton(label: label, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
