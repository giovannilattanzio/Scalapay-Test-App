import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

import 'support/pump_catalog_app.dart';

Future<void> _submitSearch(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a search with no results shows a message naming the query', (
    tester,
  ) async {
    await pumpCatalogApp(
      tester,
      onSearch: (_) async =>
          const Result.success(ProductSearchResult(products: [], page: 1)),
    );

    await _submitSearch(tester, 'zzzqqq');

    expect(
      find.text('catalog.empty'.tr(namedArgs: {'query': 'zzzqqq'})),
      findsOneWidget,
    );
  });

  testWidgets(
    'a failed search shows an error, and retry repeats it and shows the results',
    (tester) async {
      var calls = 0;
      await pumpCatalogApp(
        tester,
        onSearch: (params) async {
          calls++;
          if (calls == 1) {
            return const Result.error(ServerFailure(message: 'boom'));
          }
          return const Result.success(
            ProductSearchResult(products: [], page: 1),
          );
        },
      );

      await _submitSearch(tester, 'nike');

      expect(find.text('catalog.error_server'.tr()), findsOneWidget);

      await tester.tap(find.text('catalog.retry'.tr()));
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.text('catalog.error_server'.tr()), findsNothing);
      expect(
        find.text('catalog.empty'.tr(namedArgs: {'query': 'nike'})),
        findsOneWidget,
      );
    },
  );
}
