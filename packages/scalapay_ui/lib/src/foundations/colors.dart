import 'package:flutter/painting.dart';

/// Color tokens. Values come from the Figma variables; names are semantic.
///
/// Figma names in comments. `error` and `textDisabled` are placeholders: the
/// error color is not in the design yet and the disabled role of Grayscale/600
/// is assumed.
///
/// A few text-on-background pairs fall below the WCAG AA 4.5:1 contrast
/// minimum. They are kept at their Figma values on purpose (a user decision
/// to raise with design, not a silent gap) and documented here:
/// - `textSecondary` on `background`: 3.44:1 (UI/Grayscale/700, used for
///   secondary texts, hint and field labels).
/// - `textSecondary` on `surface`: 3.22:1 (same token, light background).
/// - `error` on `background`: 4.38:1 (placeholder value, not in Figma).
/// - `textDisabled` on `background`: ~2.68:1 and `textDisabled` on `border`:
///   ~2.37:1 (WCAG 1.4.3 exempts text of inactive controls).
///
/// `test/contrast_test.dart` computes these ratios and enforces this exact
/// list: a pair dropping below 4.5:1 without being documented here fails
/// the test, and a documented exception reaching 4.5:1 or drifting from its
/// recorded ratio fails it too.
class ScalapayColors {
  const ScalapayColors({
    this.primary = const Color(0xFF5666F0), // Brand/Colors/Core/Lilac/900
    this.onPrimary = const Color(0xFFFFFFFF), // Typography/Buttons/Active/White
    this.primaryMuted = const Color(
      0xFFCACCF2,
    ), // UI/Buttons/Lightweight/Lillac/Hover
    this.background = const Color(0xFFFFFFFF), // UI/Grayscale/100 - White
    this.surface = const Color(
      0xFFF6F7FB,
    ), // UI/Grayscale/200 and /300 - Light Background
    this.border = const Color(0xFFEFF1F5), // UI/Grayscale/500, UI/Border/300
    this.textPrimary = const Color(0xFF272727), // UI/Grayscale/900 - Black Dark
    this.textSecondary = const Color(0xFF8A8A8D), // UI/Grayscale/700
    this.textStoreName = const Color(0xFF3A4045), // UI/Grayscale/850 - Black
    // Same value as `textStoreName`, different role: the color of a text
    // field's value, not the store name text.
    this.textInput = const Color(0xFF3A4045), // UI/Grayscale/850
    this.textDisabled = const Color(
      0xFF9E9E9E,
    ), // UI/Grayscale/600 (assumed role)
    this.overlay = const Color(0xFF272727), // UI/Overlay/Pop-up
    this.error = const Color(0xFFD64545), // PLACEHOLDER, not in Figma
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryMuted;
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textStoreName;
  final Color textInput;
  final Color textDisabled;
  final Color overlay;
  final Color error;

  ScalapayColors lerp(ScalapayColors other, double t) => ScalapayColors(
    primary: Color.lerp(primary, other.primary, t)!,
    onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    primaryMuted: Color.lerp(primaryMuted, other.primaryMuted, t)!,
    background: Color.lerp(background, other.background, t)!,
    surface: Color.lerp(surface, other.surface, t)!,
    border: Color.lerp(border, other.border, t)!,
    textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    textStoreName: Color.lerp(textStoreName, other.textStoreName, t)!,
    textInput: Color.lerp(textInput, other.textInput, t)!,
    textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
    overlay: Color.lerp(overlay, other.overlay, t)!,
    error: Color.lerp(error, other.error, t)!,
  );

  /// Every token with its name, in declaration order (used by Widgetbook).
  Map<String, Color> get entries => {
    'primary': primary,
    'onPrimary': onPrimary,
    'primaryMuted': primaryMuted,
    'background': background,
    'surface': surface,
    'border': border,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'textStoreName': textStoreName,
    'textInput': textInput,
    'textDisabled': textDisabled,
    'overlay': overlay,
    'error': error,
  };
}
