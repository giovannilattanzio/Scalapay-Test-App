import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import '../../../helpers/pump_app.dart';

Widget _sliver(LoadMoreStatus status, {VoidCallback? onRetry}) =>
    CustomScrollView(
      slivers: [CatalogGridFooter(status: status, onRetry: onRetry)],
    );

void main() {
  testWidgets('shows a spinner while appending', (tester) async {
    await pumpApp(tester, _sliver(LoadMoreStatus.loading));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ScalapayButton), findsNothing);
  });

  testWidgets('shows the error message and a retry button on failure', (
    tester,
  ) async {
    var retries = 0;
    await pumpApp(
      tester,
      _sliver(LoadMoreStatus.failure, onRetry: () => retries++),
    );
    expect(find.text('Caricamento non riuscito. Riprova.'), findsOneWidget);
    await tester.tap(find.text('Riprova'));
    expect(retries, 1);
  });

  testWidgets('the error message is announced as a live region and retry '
      'offers a tap action', (tester) async {
    var retries = 0;
    final handle = tester.ensureSemantics();
    await pumpApp(
      tester,
      _sliver(LoadMoreStatus.failure, onRetry: () => retries++),
    );

    expect(
      tester.getSemantics(find.text('Caricamento non riuscito. Riprova.')),
      matchesSemantics(
        label: 'Caricamento non riuscito. Riprova.',
        isLiveRegion: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Riprova')),
      matchesSemantics(
        label: 'Riprova',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
    expect(retries, 0);
  });

  testWidgets('the loading spinner exposes a translated label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, _sliver(LoadMoreStatus.loading));

    expect(
      tester.getSemantics(find.byType(CircularProgressIndicator)),
      matchesSemantics(label: 'Caricamento prodotti'),
    );
    handle.dispose();
  });

  testWidgets('shows nothing while idle', (tester) async {
    await pumpApp(tester, _sliver(LoadMoreStatus.idle));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ScalapayButton), findsNothing);
  });

  testWidgets('shows nothing once exhausted', (tester) async {
    await pumpApp(tester, _sliver(LoadMoreStatus.exhausted));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ScalapayButton), findsNothing);
  });
}
