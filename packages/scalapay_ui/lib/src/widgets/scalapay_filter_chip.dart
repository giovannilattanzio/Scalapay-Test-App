import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'scalapay_icon.dart';

/// Pill chip with a leading icon and a label (for example "Filtri", "Ordina").
class ScalapayFilterChip extends StatelessWidget {
  const ScalapayFilterChip({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final ScalapayIconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: t.colors.surface,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: t.spacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScalapayIcon(icon, size: 20),
                  const SizedBox(width: 2),
                  Text(
                    label,
                    style: t.typography.p5Semibold.copyWith(
                      color: t.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
