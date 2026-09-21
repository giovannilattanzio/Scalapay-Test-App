import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'golden_utils.dart';

void main() {
  setUpAll(loadPoppins);

  testWidgets('empty with hint', (t) async {
    await expectGolden(
      t,
      ScalapaySearchField(hint: 'Cerca brand o negozi', onSubmitted: (_) {}),
      'search_field_empty',
    );
  });

  testWidgets('filled', (t) async {
    await expectGolden(
      t,
      ScalapaySearchField(
        controller: TextEditingController(text: 'Nike'),
        onSubmitted: (_) {},
      ),
      'search_field_filled',
    );
  });
}
