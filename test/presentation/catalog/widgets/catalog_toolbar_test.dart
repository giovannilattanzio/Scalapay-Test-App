import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows "Filtri" before "Ordina"', (tester) async {
    await pumpApp(tester, const CatalogToolbar());

    final chips = tester
        .widgetList<ScalapayFilterChip>(find.byType(ScalapayFilterChip))
        .toList();
    expect(chips.map((c) => c.label), ['Filtri', 'Ordina']);
  });

  testWidgets('tapping each chip calls its own callback', (tester) async {
    var filters = 0;
    var sort = 0;
    await pumpApp(
      tester,
      CatalogToolbar(
        onFiltersPressed: () => filters++,
        onSortPressed: () => sort++,
      ),
    );

    await tester.tap(find.text('Filtri'));
    expect((filters, sort), (1, 0));
    await tester.tap(find.text('Ordina'));
    expect((filters, sort), (1, 1));
  });
}
