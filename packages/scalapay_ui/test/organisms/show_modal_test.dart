import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

enum _Sort { priceAsc, priceDesc }

const _options = <_Sort, String>{
  _Sort.priceAsc: 'Prezzo crescente',
  _Sort.priceDesc: 'Prezzo decrescente',
};

Widget _app(Future<void> Function(BuildContext context) onOpen) => MaterialApp(
  theme: ScalapayTheme.light(),
  home: Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => onOpen(context),
          child: const Text('open'),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Ways to dismiss a sheet without choosing anything.
final _dismissals = <String, Future<void> Function(WidgetTester, Finder)>{
  'close button': (tester, sheet) async {
    await tester.tap(find.byType(ScalapayIcon));
  },
  'backdrop tap': (tester, sheet) async {
    await tester.tapAt(const Offset(10, 10));
  },
  'drag down': (tester, sheet) async {
    await tester.fling(sheet, const Offset(0, 500), 2000);
  },
};

void main() {
  group('sort sheet', () {
    Future<(_Sort? Function(), int Function())> pumpSort(
      WidgetTester tester,
    ) async {
      _Sort? result;
      var closes = 0;
      await tester.pumpWidget(
        _app((context) async {
          result = await ScalapaySortBottomSheet.show<_Sort>(
            context,
            title: 'Ordina',
            options: _options,
            selected: _Sort.priceAsc,
            onClose: () => closes++,
          );
        }),
      );
      return (() => result, () => closes);
    }

    for (final entry in _dismissals.entries) {
      testWidgets(
        '${entry.key} closes it, returns null and calls onClose once',
        (tester) async {
          final (result, closes) = await pumpSort(tester);
          await _open(tester);
          final sheet = find.byType(ScalapaySortBottomSheet<_Sort>);
          expect(sheet, findsOneWidget);

          await entry.value(tester, sheet);
          await tester.pumpAndSettle();

          expect(sheet, findsNothing);
          expect(result(), isNull);
          expect(closes(), 1);
        },
      );
    }

    testWidgets('choosing an option returns its value after the delay', (
      tester,
    ) async {
      final (result, closes) = await pumpSort(tester);
      await _open(tester);
      await tester.tap(find.text('Prezzo decrescente'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(ScalapaySortBottomSheet<_Sort>), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(ScalapaySortBottomSheet<_Sort>), findsNothing);
      expect(result(), _Sort.priceDesc);
      expect(closes(), 0);
    });

    testWidgets('the choice is shown as selected before closing', (
      tester,
    ) async {
      await pumpSort(tester);
      await _open(tester);
      await tester.tap(find.text('Prezzo decrescente'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(ScalapaySortBottomSheet<_Sort>), findsOneWidget);
      final group = tester
          .widget<ScalapayRadio<_Sort>>(
            find.byWidgetPredicate(
              (w) => w is ScalapayRadio<_Sort> && w.value == _Sort.priceDesc,
            ),
          )
          .groupValue;
      expect(group, _Sort.priceDesc);

      await tester.pumpAndSettle();
    });

    testWidgets('choosing again during the delay restarts it', (tester) async {
      final (result, closes) = await pumpSort(tester);
      await _open(tester);
      await tester.tap(find.text('Prezzo decrescente'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Prezzo crescente'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ScalapaySortBottomSheet<_Sort>), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.byType(ScalapaySortBottomSheet<_Sort>), findsNothing);
      expect(result(), _Sort.priceAsc);
      expect(closes(), 0);
    });

    // Drag down is left out: the fling itself outlasts the delay.
    for (final entry in _dismissals.entries.where(
      (e) => e.key != 'drag down',
    )) {
      testWidgets(
        '${entry.key} during the delay returns null and calls onClose once',
        (tester) async {
          final (result, closes) = await pumpSort(tester);
          await _open(tester);
          final sheet = find.byType(ScalapaySortBottomSheet<_Sort>);
          await tester.tap(find.text('Prezzo decrescente'));
          await tester.pump(const Duration(milliseconds: 100));

          await entry.value(tester, sheet);
          await tester.pumpAndSettle();
          expect(sheet, findsNothing);
          expect(result(), isNull);
          expect(closes(), 1);

          await tester.pump(const Duration(milliseconds: 500));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(closes(), 1);
        },
      );
    }
  });

  group('filters sheet', () {
    Future<
      ({int Function() closes, int Function() clears, int Function() applies})
    >
    pumpFilters(WidgetTester tester) async {
      var closes = 0, clears = 0, applies = 0;
      await tester.pumpWidget(
        _app((context) async {
          await ScalapayFiltersBottomSheet.show(
            context,
            title: 'Filtri',
            priceTitle: 'Fascia di prezzo',
            minLabel: 'Minimo',
            maxLabel: 'Massimo',
            clearLabel: 'Cancella tutto',
            applyLabel: 'Mostra risultati',
            onClose: () => closes++,
            onClear: () => clears++,
            onApply: () => applies++,
          );
        }),
      );
      return (
        closes: () => closes,
        clears: () => clears,
        applies: () => applies,
      );
    }

    for (final entry in _dismissals.entries) {
      testWidgets('${entry.key} closes it and calls onClose once', (
        tester,
      ) async {
        final calls = await pumpFilters(tester);
        await _open(tester);
        final sheet = find.byType(ScalapayFiltersBottomSheet);
        expect(sheet, findsOneWidget);

        await entry.value(tester, sheet);
        await tester.pumpAndSettle();

        expect(sheet, findsNothing);
        expect(calls.closes(), 1);
        expect(calls.applies(), 0);
      });
    }

    testWidgets('apply calls onApply and closes without calling onClose', (
      tester,
    ) async {
      final calls = await pumpFilters(tester);
      await _open(tester);
      await tester.tap(find.text('Mostra risultati'));
      await tester.pumpAndSettle();

      expect(find.byType(ScalapayFiltersBottomSheet), findsNothing);
      expect(calls.applies(), 1);
      expect(calls.closes(), 0);
    });

    testWidgets('clear calls onClear and leaves the modal open', (
      tester,
    ) async {
      final calls = await pumpFilters(tester);
      await _open(tester);
      await tester.tap(find.text('Cancella tutto'));
      await tester.pumpAndSettle();

      expect(find.byType(ScalapayFiltersBottomSheet), findsOneWidget);
      expect(calls.clears(), 1);
      expect(calls.closes(), 0);
    });

    testWidgets('the content stays above the keyboard', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(tester.view.reset);
      await pumpFilters(tester);
      await _open(tester);
      final bottomBefore = tester
          .getBottomLeft(find.byType(ScalapayFiltersBottomSheet))
          .dy;
      expect(bottomBefore, 1000);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      final bottomAfter = tester
          .getBottomLeft(find.byType(ScalapayFiltersBottomSheet))
          .dy;
      expect(bottomAfter, lessThanOrEqualTo(700));
    });
  });

  group('bottom system inset', () {
    // Measured scenario: a 393x852 screen with a 34px home indicator, the
    // device that surfaced the defect.
    const screenSize = Size(393, 852);
    const insetBottom = 34.0;
    const safeBottom = 852.0 - insetBottom;

    Future<void> pumpWithInset(
      WidgetTester tester,
      Future<void> Function(BuildContext) onOpen,
    ) async {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: insetBottom);
      tester.view.viewPadding = const FakeViewPadding(bottom: insetBottom);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(onOpen));
      await _open(tester);
    }

    testWidgets("the filters sheet's apply button ends above the inset", (
      tester,
    ) async {
      await pumpWithInset(tester, (context) async {
        await ScalapayFiltersBottomSheet.show(
          context,
          title: 'Filtri',
          priceTitle: 'Fascia di prezzo',
          minLabel: 'Minimo',
          maxLabel: 'Massimo',
          clearLabel: 'Cancella tutto',
          applyLabel: 'Mostra risultati',
          onClear: () {},
          onApply: () {},
        );
      });
      final button = find.widgetWithText(ScalapayButton, 'Mostra risultati');
      expect(tester.getBottomLeft(button).dy, lessThanOrEqualTo(safeBottom));
    });

    testWidgets("the sort sheet's last option ends above the inset", (
      tester,
    ) async {
      await pumpWithInset(tester, (context) async {
        await ScalapaySortBottomSheet.show<_Sort>(
          context,
          title: 'Ordina',
          options: _options,
          selected: _Sort.priceAsc,
        );
      });
      final lastOption = find.byType(ScalapayRadio<_Sort>).last;
      expect(
        tester.getBottomLeft(lastOption).dy,
        lessThanOrEqualTo(safeBottom),
      );
    });
  });

  group('modal look', () {
    testWidgets(
      'the backdrop uses the overlay color and no surface shows behind the corners',
      (tester) async {
        await tester.pumpWidget(
          _app((context) async {
            await ScalapaySortBottomSheet.show<_Sort>(
              context,
              title: 'Ordina',
              options: _options,
            );
          }),
        );
        await _open(tester);

        final barrier = tester.widget<ModalBarrier>(
          find.byType(ModalBarrier).last,
        );
        expect(
          barrier.color,
          const ScalapayColors().overlay.withValues(alpha: 0.5),
        );

        final surface = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(BottomSheet),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(surface.color, Colors.transparent);
        expect(surface.elevation, 0);
      },
    );
  });

  group('closeLabel passthrough', () {
    testWidgets('ScalapaySortBottomSheet.show passes closeLabel through', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app((context) async {
          await ScalapaySortBottomSheet.show<_Sort>(
            context,
            title: 'Ordina',
            options: _options,
            selected: _Sort.priceAsc,
            closeLabel: 'Chiudi ordinamento',
          );
        }),
      );
      await _open(tester);

      expect(find.bySemanticsLabel('Chiudi ordinamento'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('ScalapayFiltersBottomSheet.show passes closeLabel through', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app((context) async {
          await ScalapayFiltersBottomSheet.show(
            context,
            title: 'Filtri',
            priceTitle: 'Fascia di prezzo',
            minLabel: 'Minimo',
            maxLabel: 'Massimo',
            clearLabel: 'Cancella tutto',
            applyLabel: 'Mostra risultati',
            closeLabel: 'Chiudi filtri',
          );
        }),
      );
      await _open(tester);

      expect(find.bySemanticsLabel('Chiudi filtri'), findsOneWidget);
      handle.dispose();
    });
  });

  group('large text (200%)', () {
    Widget appAtScale(Future<void> Function(BuildContext) onOpen) =>
        MaterialApp(
          theme: ScalapayTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => onOpen(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );

    const longOptions = <_Sort, String>{
      _Sort.priceAsc: 'Prezzo crescente dal più basso al più alto',
      _Sort.priceDesc: 'Prezzo decrescente dal più alto al più basso',
    };

    testWidgets('sort sheet opened via show shows every long option without '
        'overflow at 200% text scale', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        appAtScale((context) async {
          await ScalapaySortBottomSheet.show<_Sort>(
            context,
            title: 'Ordina',
            options: longOptions,
            selected: _Sort.priceAsc,
          );
        }),
      );
      await _open(tester);

      expect(tester.takeException(), isNull);
      for (final label in longOptions.values) {
        await tester.scrollUntilVisible(find.text(label), 200);
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets(
      'filters sheet opened via show shows both footer buttons without '
      'overflow at 200% text scale',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          appAtScale((context) async {
            await ScalapayFiltersBottomSheet.show(
              context,
              title: 'Filtri',
              priceTitle: 'Fascia di prezzo molto lunga da visualizzare',
              minLabel: 'Minimo',
              maxLabel: 'Massimo',
              clearLabel: 'Cancella tutto',
              applyLabel: 'Mostra risultati',
              onClear: () {},
              onApply: () {},
            );
          }),
        );
        await _open(tester);

        expect(tester.takeException(), isNull);
        // The two price fields' EditableText each own a Scrollable too, so
        // the outer one (the one scrolling the whole sheet) is picked out by
        // its ancestry, not by type alone.
        final outerScrollable = find
            .ancestor(
              of: find.byType(ScalapayFiltersBottomSheet),
              matching: find.byType(Scrollable),
            )
            .first;
        for (final label in ['Cancella tutto', 'Mostra risultati']) {
          await tester.scrollUntilVisible(
            find.text(label),
            200,
            scrollable: outerScrollable,
          );
          expect(find.text(label), findsOneWidget);
        }
      },
    );
  });

  group('accessibility - tap target guidelines', () {
    testWidgets('sort sheet opened via show meets tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app((context) async {
          await ScalapaySortBottomSheet.show<_Sort>(
            context,
            title: 'Ordina',
            options: _options,
            selected: _Sort.priceAsc,
          );
        }),
      );
      await _open(tester);

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('filters sheet opened via show meets tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app((context) async {
          await ScalapayFiltersBottomSheet.show(
            context,
            title: 'Filtri',
            priceTitle: 'Fascia di prezzo',
            minLabel: 'Minimo',
            maxLabel: 'Massimo',
            clearLabel: 'Cancella tutto',
            applyLabel: 'Mostra risultati',
            onClear: () {},
            onApply: () {},
          );
        }),
      );
      await _open(tester);

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });
  });
}
