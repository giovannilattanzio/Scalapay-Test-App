import 'package:flutter/material.dart';

import '../foundations/foundations.dart';

/// All design tokens, attached to `ThemeData.extensions`.
@immutable
class ScalapayTokens extends ThemeExtension<ScalapayTokens> {
  const ScalapayTokens({
    this.colors = const ScalapayColors(),
    this.typography = const ScalapayTypography(),
    this.spacing = const ScalapaySpacing(),
    this.radius = const ScalapayRadius(),
  });

  final ScalapayColors colors;
  final ScalapayTypography typography;
  final ScalapaySpacing spacing;
  final ScalapayRadius radius;

  @override
  ScalapayTokens copyWith({
    ScalapayColors? colors,
    ScalapayTypography? typography,
    ScalapaySpacing? spacing,
    ScalapayRadius? radius,
  }) => ScalapayTokens(
    colors: colors ?? this.colors,
    typography: typography ?? this.typography,
    spacing: spacing ?? this.spacing,
    radius: radius ?? this.radius,
  );

  @override
  ScalapayTokens lerp(ThemeExtension<ScalapayTokens>? other, double t) {
    if (other is! ScalapayTokens) return this;
    return ScalapayTokens(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      spacing: t < 0.5 ? spacing : other.spacing,
      radius: t < 0.5 ? radius : other.radius,
    );
  }
}
