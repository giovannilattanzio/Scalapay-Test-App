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

  // Figma draws the "order" glyph on a 24px grid, flush with the icon's own
  // bounds (no gap before the label), while every other chip icon sits on a
  // 20px grid with a small gap before the label. None of these measured
  // values have a token, so they are named private constants instead of
  // magic numbers.
  static const _orderIconLeft = 4.0;
  static const _orderIconSize = 24.0;
  static const _orderGap = 0.0;
  static const _iconSize = 20.0;
  static const _iconGap = 2.0;
  static const _defaultRight = 10.0;

  /// Left padding, icon size, gap before the label and right padding, per
  /// icon. `order` uses its own 24px grid; every other icon shares the 20px
  /// layout.
  (double left, double iconSize, double gap, double right) _layout(
    ScalapayTokens t,
  ) => switch (icon) {
    ScalapayIconData.order => (
      _orderIconLeft,
      _orderIconSize,
      _orderGap,
      t.spacing.xs,
    ),
    _ => (t.spacing.xs, _iconSize, _iconGap, _defaultRight),
  };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (left, iconSize, gap, right) = _layout(t);
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
              padding: EdgeInsets.only(left: left, right: right),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScalapayIcon(icon, size: iconSize),
                  SizedBox(width: gap),
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
