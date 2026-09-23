import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

enum _Sort { priceAsc, priceDesc, nameAsc, nameDesc }

const _options = <_Sort, String>{
  _Sort.priceAsc: 'Prezzo crescente',
  _Sort.priceDesc: 'Prezzo decrescente',
  _Sort.nameAsc: 'Nome A-Z',
  _Sort.nameDesc: 'Nome Z-A',
};

Widget _host(Widget child, {double width = 375}) => MaterialApp(
  theme: ScalapayTheme.light(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

ScalapaySortBottomSheet<_Sort> _sheet({
  _Sort? selected = _Sort.priceAsc,
  ValueChanged<_Sort>? onChanged,
  VoidCallback? onClose,
}) => ScalapaySortBottomSheet<_Sort>(
  title: 'Ordina',
  options: _options,
  selected: selected,
  onChanged: onChanged,
  onClose: onClose,
);

void main() {
  testWidgets(
    'shows the title and the labels in the given order, and nothing else',
    (tester) async {
      await tester.pumpWidget(_host(_sheet()));
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .toList();
      expect(texts, [
        'Ordina',
        'Prezzo crescente',
        'Prezzo decrescente',
        'Nome A-Z',
        'Nome Z-A',
      ]);
    },
  );

  testWidgets('the selected option is marked, the others are not', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_sheet(selected: _Sort.nameAsc)));
    final radios = find.byType(ScalapayRadio<_Sort>);
    expect(radios, findsNWidgets(4));
    for (var i = 0; i < 4; i++) {
      final isChecked = _options.keys.elementAt(i) == _Sort.nameAsc;
      expect(
        tester.getSemantics(radios.at(i)),
        matchesSemantics(
          label: _options.values.elementAt(i),
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: isChecked,
          // A selected radio has no tap action (tapping it would re-report
          // the same value); an unselected one does.
          hasTapAction: !isChecked,
        ),
        reason: _options.values.elementAt(i),
      );
    }
  });

  testWidgets('without a selected value no option is marked', (tester) async {
    await tester.pumpWidget(_host(_sheet(selected: null)));
    final radios = find.byType(ScalapayRadio<_Sort>);
    for (var i = 0; i < 4; i++) {
      expect(
        tester.getSemantics(radios.at(i)),
        matchesSemantics(
          label: _options.values.elementAt(i),
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: false,
          hasTapAction: true,
        ),
      );
    }
  });

  testWidgets(
    'choosing an unselected option calls onChanged once with its value',
    (tester) async {
      final calls = <_Sort>[];
      await tester.pumpWidget(_host(_sheet(onChanged: calls.add)));
      await tester.tap(find.text('Nome Z-A'));
      expect(calls, [_Sort.nameDesc]);
    },
  );

  testWidgets('choosing the selected option does not call onChanged', (
    tester,
  ) async {
    final calls = <_Sort>[];
    await tester.pumpWidget(_host(_sheet(onChanged: calls.add)));
    await tester.tap(find.text('Prezzo crescente'));
    expect(calls, isEmpty);
  });

  testWidgets('each row is 64 tall and a four-option card is 256 tall', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_sheet()));
    for (var i = 0; i < 4; i++) {
      expect(
        tester.getSize(find.byKey(ValueKey('sort-option-row-$i'))).height,
        64,
      );
    }

    final radios = find.byType(ScalapayRadio<_Sort>);
    final card = find
        .ancestor(of: radios.first, matching: find.byType(DecoratedBox))
        .first;
    expect(tester.getSize(card).height, 256);
  });

  testWidgets('dividers separate the options and none follows the last', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_sheet()));
    final dividers = find.byType(ScalapayDivider);
    expect(dividers, findsNWidgets(3));
    final radios = find.byType(ScalapayRadio<_Sort>);
    for (var i = 0; i < 3; i++) {
      final dividerTop = tester.getTopLeft(dividers.at(i)).dy;
      expect(
        dividerTop,
        greaterThanOrEqualTo(tester.getBottomLeft(radios.at(i)).dy),
      );
      expect(
        dividerTop,
        lessThanOrEqualTo(tester.getTopLeft(radios.at(i + 1)).dy),
      );
    }
    // Nothing below the last option but the card and sheet padding.
    final lastRadioBottom = tester.getBottomLeft(radios.at(3)).dy;
    final sheetBottom = tester
        .getBottomLeft(find.byType(ScalapaySortBottomSheet<_Sort>))
        .dy;
    for (var i = 0; i < 3; i++) {
      expect(tester.getTopLeft(dividers.at(i)).dy, lessThan(lastRadioBottom));
    }
    expect(sheetBottom, greaterThan(lastRadioBottom));
  });

  testWidgets('works with a value type chosen by the caller', (tester) async {
    final calls = <int>[];
    await tester.pumpWidget(
      _host(
        ScalapaySortBottomSheet<int>(
          title: 'Sort',
          options: const {1: 'One', 2: 'Two'},
          selected: 1,
          onChanged: calls.add,
        ),
      ),
    );
    await tester.tap(find.text('Two'));
    expect(calls, [2]);
  });

  testWidgets('the close button calls onClose once', (tester) async {
    var closes = 0;
    await tester.pumpWidget(_host(_sheet(onClose: () => closes++)));
    await tester.tap(find.byType(ScalapayIcon));
    expect(closes, 1);
  });

  testWidgets('its height follows the content in a tall parent', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_sheet()));
    final height = tester
        .getSize(find.byType(ScalapaySortBottomSheet<_Sort>))
        .height;
    expect(height, lessThan(400));
    expect(height, greaterThan(300));
  });

  group('large text', () {
    const longOptions = <_Sort, String>{
      _Sort.priceAsc: 'Prezzo crescente dal più basso al più alto',
      _Sort.priceDesc: 'Prezzo decrescente dal più alto al più basso',
      _Sort.nameAsc: 'Nome in ordine alfabetico crescente da A a Z',
      _Sort.nameDesc: 'Nome in ordine alfabetico decrescente da Z a A',
    };

    testWidgets(
      'standalone: no overflow and every long option is visible at 200% '
      'text scale',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: ScalapayTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: ScalapaySortBottomSheet<_Sort>(
                  title: 'Ordina',
                  options: longOptions,
                  selected: _Sort.priceAsc,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        for (final label in longOptions.values) {
          await tester.scrollUntilVisible(find.text(label), 200);
          expect(find.text(label), findsOneWidget);
        }
      },
    );
  });

  group('accessibility - tap target guidelines', () {
    testWidgets('standalone sheet meets tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(_sheet(onClose: () {})));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });
  });
}
