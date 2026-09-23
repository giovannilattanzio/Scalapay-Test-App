import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows only the message when there is no action', (tester) async {
    await pumpApp(tester, const CatalogMessage(message: 'Nothing here'));

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byType(ScalapayButton), findsNothing);
  });

  testWidgets('shows an action button that calls onAction once tapped', (
    tester,
  ) async {
    var taps = 0;
    await pumpApp(
      tester,
      CatalogMessage(
        message: 'Something failed',
        actionLabel: 'Riprova',
        onAction: () => taps++,
      ),
    );

    expect(find.text('Riprova'), findsOneWidget);
    await tester.tap(find.text('Riprova'));
    expect(taps, 1);
  });

  testWidgets('CatalogLoading shows a centered progress indicator', (
    tester,
  ) async {
    await pumpApp(tester, const CatalogLoading());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('CatalogLoading exposes a translated label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, const CatalogLoading());

    expect(
      tester.getSemantics(find.byType(CircularProgressIndicator)),
      matchesSemantics(label: 'Caricamento prodotti'),
    );
    handle.dispose();
  });

  testWidgets('the message is announced as a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, const CatalogMessage(message: 'Nothing here'));

    expect(
      tester.getSemantics(find.text('Nothing here')),
      matchesSemantics(label: 'Nothing here', isLiveRegion: true),
    );
    handle.dispose();
  });
}
