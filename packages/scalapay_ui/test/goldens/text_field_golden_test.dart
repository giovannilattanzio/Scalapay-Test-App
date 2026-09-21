import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'golden_utils.dart';

void main() {
  setUpAll(loadPoppins);

  testWidgets('empty', (t) async {
    await expectGolden(
      t,
      const ScalapayTextField(
        label: 'Minimo',
        keyboardType: TextInputType.number,
      ),
      'text_field_empty',
      width: 200,
    );
  });

  testWidgets('filled with floated label', (t) async {
    await expectGolden(
      t,
      ScalapayTextField(
        label: 'Minimo',
        controller: TextEditingController(text: '150'),
      ),
      'text_field_filled',
      width: 200,
    );
  });

  testWidgets('error', (t) async {
    await expectGolden(
      t,
      ScalapayTextField(
        label: 'Minimo',
        controller: TextEditingController(text: 'abc'),
        errorText: 'Valore non valido',
      ),
      'text_field_error',
      width: 200,
    );
  });
}
