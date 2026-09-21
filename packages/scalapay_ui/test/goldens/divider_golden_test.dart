import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'golden_utils.dart';

void main() {
  setUpAll(loadPoppins);

  testWidgets('default', (t) async {
    await expectGolden(
      t,
      const ScalapayDivider(),
      'divider_default',
      width: 200,
    );
  });
}
