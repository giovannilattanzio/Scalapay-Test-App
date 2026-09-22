import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'support/product_fixtures.dart';
import 'support/pump_catalog_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'applying a price range in the filters sheet reloads the results restricted to it',
    (tester) async {
      PriceRange? requestedRange;
      await pumpCatalogApp(
        tester,
        onSearch: (params) async {
          requestedRange = params.priceRange;
          final ids = params.priceRange == PriceRange.none
              ? idsFrom(0, 2)
              : idsFrom(20, 2);
          return Result.success(
            ProductSearchResult(products: productFixtures(ids), page: 1),
          );
        },
      );

      await tester.enterText(find.byType(TextField), 'nike');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Product 0'), findsOneWidget);

      await tester.tap(find.text('catalog.filters'.tr()));
      await tester.pumpAndSettle();

      // The header's search field is also a `TextField`: scope to the sheet
      // so its two price fields are `.at(0)`/`.at(1)` (see
      // test/presentation/catalog/pages/catalog_bottom_sheets_test.dart).
      final priceFields = find.descendant(
        of: find.byType(ScalapayFiltersBottomSheet),
        matching: find.byType(TextField),
      );
      await tester.enterText(priceFields.at(0), '100');
      await tester.enterText(priceFields.at(1), '200');
      await tester.tap(find.text('filters.apply'.tr()));
      await tester.pumpAndSettle();

      expect(requestedRange, const PriceRange(min: 100, max: 200));
      expect(find.text('Product 20'), findsOneWidget);
      expect(find.text('Product 0'), findsNothing);
    },
  );
}
