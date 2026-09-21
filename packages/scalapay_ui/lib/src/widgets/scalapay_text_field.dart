import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';

/// Outlined text field whose label floats above the value once the field has
/// content or focus. Shows [errorText] with the error styling when provided.
class ScalapayTextField extends StatelessWidget {
  const ScalapayTextField({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  /// Restricts what the user can type or paste. Null accepts any text.
  final List<TextInputFormatter>? inputFormatters;

  // Starting point (56 - 19.5) / 2 = 18.25 (the p3Medium line height is
  // 19.5), tuned down to 18.0 because Material's InputDecorator adds half a
  // logical pixel of its own. Makes the outlined field exactly 56 tall,
  // empty or filled, without an error. No spacing token matches this
  // measured value.
  static const _verticalPadding = 18.0;

  // Flutter's InputDecorator always scales the floated label by its private
  // `_kFinalLabelScale` constant (flutter/lib/src/material/input_decorator.dart),
  // so a floatingLabelStyle fontSize is rendered at 75% of its value. Divide
  // by this to make the floated label actually render at the token's size
  // (p5 = 11) instead of 11 * 0.75 = 8.25.
  static const _floatingLabelScale = 0.75;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.radius.child),
      borderSide: BorderSide(color: color),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: t.typography.p3Medium.copyWith(color: t.colors.textInput),
      cursorColor: t.colors.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: t.typography.p3Medium.copyWith(
          color: t.colors.textSecondary,
        ),
        floatingLabelStyle: t.typography.p5.copyWith(
          fontSize: t.typography.p5.fontSize! / _floatingLabelScale,
          color: errorText == null ? t.colors.textSecondary : t.colors.error,
        ),
        errorText: errorText,
        errorStyle: t.typography.p5.copyWith(color: t.colors.error),
        filled: true,
        fillColor: t.colors.background,
        // Vertical padding tuned so the outlined field (whose label floats
        // onto the border and adds no height of its own) measures exactly
        // 56 total: (56 - lineHeight) / 2 with the p3Medium line height
        // (19.5 logical px).
        contentPadding: EdgeInsets.symmetric(
          horizontal: t.spacing.s,
          vertical: _verticalPadding,
        ),
        enabledBorder: border(t.colors.border),
        focusedBorder: border(t.colors.primary),
        errorBorder: border(t.colors.error),
        focusedErrorBorder: border(t.colors.error),
      ),
    );
  }
}
