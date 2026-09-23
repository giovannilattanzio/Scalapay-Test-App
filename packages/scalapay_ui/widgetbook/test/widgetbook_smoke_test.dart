import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:scalapay_widgetbook/main.dart';
import 'package:scalapay_widgetbook/main.directories.g.dart';
import 'package:widgetbook/widgetbook.dart';

import 'support/use_case_routes.dart';

/// Opens Widgetbook on [route] and checks that Widgetbook selected it.
Future<void> _openRoute(WidgetTester tester, UseCaseRoute target) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // Encoded: a '+' in a query would be read as a space.
  final initialRoute = Uri(
    path: '/',
    queryParameters: {'path': target.route},
  ).toString();
  await tester.pumpWidget(WidgetbookApp(initialRoute: initialRoute));
  await tester.pumpAndSettle();

  final state = WidgetbookState.of(tester.element(find.text('Search').first));
  expect(
    state.useCase?.path,
    target.useCase.path,
    reason: 'route ${target.route} did not select its use case',
  );
}

void main() {
  testWidgets('Widgetbook launches with the design system theme', (
    tester,
  ) async {
    await tester.pumpWidget(const WidgetbookApp());
    await tester.pumpAndSettle();
    expect(find.byType(WidgetbookApp), findsOneWidget);
  });

  test('every atom, molecule, organism and foundation has a use case', () {
    final names = <String>{};
    void walk(List<WidgetbookNode> nodes) {
      for (final n in nodes) {
        names.add(n.name);
        walk(n.children ?? const []);
      }
    }

    walk(directories);
    for (final expected in [
      'ScalapayButton',
      'ScalapayFilterChip',
      'ScalapaySearchField',
      'ScalapayTextField',
      'ScalapayRadio',
      'ScalapayIcon',
      'ScalapayDivider',
      'ScalapayProductCard',
      'ScalapayFiltersBottomSheet',
      'ScalapaySortBottomSheet',
      'ScalapayColors',
      'ScalapayTypography',
      'ScalapaySpacing',
      'ScalapayRadius',
    ]) {
      expect(names, contains(expected));
    }
  });

  group('every use case renders inside Widgetbook without errors', () {
    final routes = useCaseRoutes();

    test('use cases were discovered', () => expect(routes, isNotEmpty));

    for (final target in routes) {
      testWidgets(target.route, (tester) async {
        await _openRoute(tester, target);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the "Open as modal" use cases open the modal inside Widgetbook', () {
    for (final (folderAndType, buttonLabel, isSheet)
        in <(String, String, bool Function(Widget))>[
          (
            'organisms/scalapayfiltersbottomsheet',
            'Open filters',
            (w) => w is ScalapayFiltersBottomSheet,
          ),
          (
            'organisms/scalapaysortbottomsheet',
            'Open sort',
            // Any value type: the use case uses its own enum.
            (w) => w is ScalapaySortBottomSheet,
          ),
        ]) {
      testWidgets(folderAndType, (tester) async {
        final target = useCaseRoutes().firstWhere(
          (r) => r.route == '$folderAndType/open-as-modal',
        );
        await _openRoute(tester, target);

        await tester.tap(find.text(buttonLabel));
        await tester.pumpAndSettle();

        expect(find.byWidgetPredicate(isSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
