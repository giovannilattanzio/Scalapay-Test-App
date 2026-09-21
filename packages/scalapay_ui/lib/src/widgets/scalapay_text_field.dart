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
      style: t.typography.p3Medium.copyWith(color: t.colors.textPrimary),
      cursorColor: t.colors.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: t.typography.p3Medium.copyWith(
          color: t.colors.textSecondary,
        ),
        floatingLabelStyle: t.typography.p5.copyWith(
          color: errorText == null ? t.colors.textSecondary : t.colors.error,
        ),
        errorText: errorText,
        errorStyle: t.typography.p5.copyWith(color: t.colors.error),
        filled: true,
        fillColor: t.colors.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: t.spacing.s,
          vertical: t.spacing.s,
        ),
        enabledBorder: border(t.colors.border),
        focusedBorder: border(t.colors.primary),
        errorBorder: border(t.colors.error),
        focusedErrorBorder: border(t.colors.error),
      ),
    );
  }
}
