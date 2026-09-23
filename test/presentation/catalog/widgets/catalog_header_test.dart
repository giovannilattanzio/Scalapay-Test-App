import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the title and the search field', (tester) async {
    await pumpApp(tester, const CatalogHeader());

    expect(find.text('Esplora i prodotti'), findsOneWidget);
    expect(find.byType(ScalapaySearchField), findsOneWidget);
  });

  testWidgets('submitting the search field calls onSearch with the text', (
    tester,
  ) async {
    String? submitted;
    await pumpApp(
      tester,
      CatalogHeader(onSearch: (value) => submitted = value),
    );

    await tester.enterText(find.byType(TextField), 'nike');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submitted, 'nike');
  });

  testWidgets('the title is exposed as a header', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, const CatalogHeader());

    expect(
      tester.getSemantics(find.text('Esplora i prodotti')),
      matchesSemantics(label: 'Esplora i prodotti', isHeader: true),
    );
    handle.dispose();
  });
}
