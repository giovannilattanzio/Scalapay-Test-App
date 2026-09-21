import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'golden_utils.dart';

void main() {
  setUpAll(loadPoppins);

  testWidgets('all icons', (t) async {
    await expectGolden(
      t,
      Wrap(
        spacing: 16,
        children: [
          for (final icon in ScalapayIconData.values)
            ScalapayIcon(icon, size: 32),
        ],
      ),
      'icon_all',
      width: 200,
    );
  });

  testWidgets('tinted', (t) async {
    await expectGolden(
      t,
      const ScalapayIcon(
        ScalapayIconData.search,
        size: 32,
        color: Color(0xFF5666F0),
      ),
      'icon_tinted',
      width: 60,
    );
  });
}
