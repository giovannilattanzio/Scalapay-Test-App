import 'package:flutter/material.dart';

import 'scalapay_tokens.dart';

/// Builds the app [ThemeData] from the design tokens.
abstract class ScalapayTheme {
  static ThemeData light({ScalapayTokens tokens = const ScalapayTokens()}) {
    final c = tokens.colors;
    final t = tokens.typography;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: c.primary,
        onPrimary: c.onPrimary,
        surface: c.background,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.surface,
        outline: c.border,
        error: c.error,
      ),
      scaffoldBackgroundColor: c.background,
      dividerColor: c.border,
      textTheme: TextTheme(
        headlineSmall: t.h2,
        titleMedium: t.p1,
        bodyMedium: t.p3Medium,
        bodySmall: t.p4,
        labelSmall: t.p5,
        labelLarge: t.button,
      ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary),
      extensions: [tokens],
    );
  }
}
