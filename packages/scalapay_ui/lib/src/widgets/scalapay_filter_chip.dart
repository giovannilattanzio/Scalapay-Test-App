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

  // 44 = Apple HIG / WCAG 2.5.5 minimum tap target; not a token because it is
  // an accessibility floor, not a design measurement (design is iOS-first).
  static const _minTapTarget = 44.0;

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
      onTap: onPressed,
      excludeSemantics: true,
      // The visible pill (below) stays 32 tall per Figma, with its own
      // InkWell so the press ink/highlight stays clipped to the pill shape.
      // This GestureDetector only forwards taps that land in the extra
      // padding above/below the pill (up to the 44 minimum, per
      // _minTapTarget); a tap on the pill itself is resolved to the inner
      // InkWell by the gesture arena (the innermost recognizer wins), so the
      // callback still fires exactly once either way.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minTapTarget),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
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
          ),
        ),
      ),
    );
  }
}
