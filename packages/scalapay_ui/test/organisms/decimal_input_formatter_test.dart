import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/src/organisms/internal/decimal_input_formatter.dart';

TextEditingValue _apply(String old, String next, {int? cursor}) =>
    const DecimalInputFormatter().formatEditUpdate(
      TextEditingValue(text: old),
      TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: cursor ?? next.length),
      ),
    );

void main() {
  group('DecimalInputFormatter', () {
    test('accepts empty, integers, decimals and a leading separator', () {
      for (final v in ['', '1500', '12.5', '.5', '5.', '2000.50']) {
        expect(_apply('', v).text, v);
      }
    });

    test('a comma becomes a period and the cursor is kept', () {
      final r = _apply('12', '12,5', cursor: 3);
      expect(r.text, '12.5');
      expect(r.selection.baseOffset, 3);
    });

    test('rejects letters, spaces and signs keeping the old value', () {
      for (final v in ['1a', 'abc', '1 2', ' ', '-1', '+1', '1e5']) {
        expect(_apply('1', v).text, '1', reason: v);
      }
    });

    test('rejects a second separator', () {
      expect(_apply('1.5', '1.5.').text, '1.5');
      expect(_apply('1.5', '1.5,').text, '1.5');
      expect(_apply('1,5', '1,,5').text, '1,5');
    });

    test('pasted text: valid accepted, invalid rejected', () {
      expect(_apply('', '1500').text, '1500');
      expect(_apply('', '12,5').text, '12.5');
      expect(_apply('7', 'abc').text, '7');
      expect(_apply('7', '1.2.3').text, '7');
      expect(_apply('7', '1.234,50').text, '7');
    });
  });
}
