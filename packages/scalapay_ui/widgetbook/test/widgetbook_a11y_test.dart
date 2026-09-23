import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_widgetbook/main.dart';
import 'package:widgetbook/widgetbook.dart';

import 'support/use_case_routes.dart';

/// Opens [target] in Widgetbook's preview mode (`?preview`, no navigation,
/// search, knobs or addon panels) on a phone-sized surface and returns the
/// [WidgetbookState] it selected.
///
/// The widget used to reach [WidgetbookState] must be a descendant of
/// Widgetbook's own `WidgetbookScope`. Widgetbook's own `MaterialApp.router`
/// (the outermost `MaterialApp`, built directly under the scope) is such a
/// widget in both normal and preview mode: `find.byType(MaterialApp).first`
/// resolves to it, ahead of the per-use-case `MaterialApp` that the default
/// `appBuilder` wraps the previewed widget in.
Future<WidgetbookState> _openPreview(
  WidgetTester tester,
  UseCaseRoute target,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final initialRoute = Uri(
    path: '/',
    queryParameters: {'path': target.route, 'preview': ''},
  ).toString();
  await tester.pumpWidget(WidgetbookApp(initialRoute: initialRoute));
  await tester.pumpAndSettle();

  final state = WidgetbookState.of(
    tester.element(find.byType(MaterialApp).first),
  );
  expect(
    state.previewMode,
    isTrue,
    reason: 'route ${target.route} did not open in preview mode',
  );
  expect(
    state.useCase?.path,
    target.useCase.path,
    reason: 'route ${target.route} did not select its use case',
  );
  return state;
}

void main() {
  final routes = useCaseRoutes();

  test('use cases were discovered', () => expect(routes, isNotEmpty));

  testWidgets('preview mode renders no Widgetbook chrome', (tester) async {
    final target = routes.first;
    final state = await _openPreview(tester, target);

    // No navigation tree, search field or addon/knobs panels: previewMode
    // forces every panel off (see WidgetbookState.canShowPanel), and no
    // panel text is on screen.
    expect(state.canShowPanel(LayoutPanel.navigation), isFalse);
    expect(state.canShowPanel(LayoutPanel.addons), isFalse);
    expect(state.canShowPanel(LayoutPanel.knobs), isFalse);
    expect(find.text('Search'), findsNothing);
  });

  group('every use case meets tap target guidelines in preview mode', () {
    for (final target in routes) {
      testWidgets(target.route, (tester) async {
        final handle = tester.ensureSemantics();

        await _openPreview(tester, target);

        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

        handle.dispose();
      });
    }
  });
}
