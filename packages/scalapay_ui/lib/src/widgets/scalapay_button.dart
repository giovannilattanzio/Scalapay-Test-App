import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Visual emphasis of a [ScalapayButton].
enum ScalapayButtonVariant {
  /// Filled lilac pill with a white label.
  primary,

  /// Label only (lilac, no background).
  tertiary,
}

/// Button in the design system. Disabled when [onPressed] is null.
///
/// The [variant] only changes the look, so every call site keeps the same
/// parameters; the default is [ScalapayButtonVariant.primary].
class ScalapayButton extends StatelessWidget {
  const ScalapayButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ScalapayButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final ScalapayButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onPressed != null;
    final (background, foreground) = switch (variant) {
      ScalapayButtonVariant.primary => (
        enabled ? t.colors.primary : t.colors.border,
        enabled ? t.colors.onPrimary : t.colors.textDisabled,
      ),
      ScalapayButtonVariant.tertiary => (
        null,
        enabled ? t.colors.primary : t.colors.textDisabled,
      ),
    };
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        // Tertiary has no fill: transparency instead of a transparent color.
        type: background == null
            ? MaterialType.transparency
            : MaterialType.canvas,
        color: background,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: t.spacing.s),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  style: t.typography.button.copyWith(color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
