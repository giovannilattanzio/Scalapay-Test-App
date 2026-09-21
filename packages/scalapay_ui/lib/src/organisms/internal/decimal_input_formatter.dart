import 'package:flutter/services.dart';

/// Accepts only digits with at most one decimal separator (`.` or `,`).
///
/// A comma becomes a period, so the text is always empty or accepted by
/// `double.tryParse`. Text that breaks the pattern is rejected whole and the
/// previous value is kept.
class DecimalInputFormatter extends TextInputFormatter {
  const DecimalInputFormatter();

  static final _pattern = RegExp(r'^\d*[.,]?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (!_pattern.hasMatch(text)) return oldValue;
    if (!text.contains(',')) return newValue;
    // One character replaces one character: selection and composing offsets
    // stay valid.
    return newValue.copyWith(text: text.replaceAll(',', '.'));
  }
}
