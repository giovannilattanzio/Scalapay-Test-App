import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'golden_utils.dart';

void main() {
  setUpAll(loadPoppins);

  testWidgets('filter', (t) async {
    await expectGolden(
      t,
      ScalapayFilterChip(
        label: 'Filtri',
        icon: ScalapayIconData.filter,
        onPressed: () {},
      ),
      'filter_chip_filter',
      width: 150,
    );
  });

  testWidgets('order', (t) async {
    await expectGolden(
      t,
      ScalapayFilterChip(
        label: 'Ordina',
        icon: ScalapayIconData.order,
        onPressed: () {},
      ),
      'filter_chip_order',
      width: 150,
    );
  });
}
