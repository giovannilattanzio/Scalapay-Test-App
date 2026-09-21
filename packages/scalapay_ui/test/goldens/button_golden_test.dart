import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'golden_utils.dart';

void main() {
  setUpAll(loadPoppins);

  testWidgets('primary enabled', (t) async {
    await expectGolden(
      t,
      ScalapayButton(label: 'Mostra risultati', onPressed: () {}),
      'button_enabled',
      width: 250,
    );
  });

  testWidgets('primary disabled', (t) async {
    await expectGolden(
      t,
      const ScalapayButton(label: 'Mostra risultati'),
      'button_disabled',
      width: 250,
    );
  });

  testWidgets('tertiary enabled', (t) async {
    await expectGolden(
      t,
      ScalapayButton(
        variant: ScalapayButtonVariant.tertiary,
        label: 'Cancella tutto',
        onPressed: () {},
      ),
      'button_tertiary_enabled',
      width: 200,
    );
  });

  testWidgets('tertiary disabled', (t) async {
    await expectGolden(
      t,
      const ScalapayButton(
        variant: ScalapayButtonVariant.tertiary,
        label: 'Cancella tutto',
      ),
      'button_tertiary_disabled',
      width: 200,
    );
  });
}
