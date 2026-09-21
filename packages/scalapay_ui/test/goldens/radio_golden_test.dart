import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'golden_utils.dart';

void main() {
  setUpAll(loadPoppins);

  testWidgets('selected', (t) async {
    await expectGolden(
      t,
      ScalapayRadio<int>(
        value: 1,
        groupValue: 1,
        label: 'Prezzo crescente',
        onChanged: (_) {},
      ),
      'radio_selected',
      width: 250,
    );
  });

  testWidgets('unselected', (t) async {
    await expectGolden(
      t,
      ScalapayRadio<int>(
        value: 2,
        groupValue: 1,
        label: 'Prezzo decrescente',
        onChanged: (_) {},
      ),
      'radio_unselected',
      width: 250,
    );
  });
}
