import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

Widget _host(Widget child, {double width = 375}) => MaterialApp(
  theme: ScalapayTheme.light(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

ScalapayFiltersBottomSheet _sheet({
  TextEditingController? min,
  TextEditingController? max,
  String? priceError,
  VoidCallback? onClose,
  VoidCallback? onClear,
  VoidCallback? onApply,
}) => ScalapayFiltersBottomSheet(
  title: 'Filtri',
  priceTitle: 'Fascia di prezzo',
  minLabel: 'Minimo',
  maxLabel: 'Massimo',
  clearLabel: 'Cancella tutto',
  applyLabel: 'Mostra risultati',
  minController: min,
  maxController: max,
  priceError: priceError,
  onClose: onClose,
  onClear: onClear,
  onApply: onApply,
);

double _labelTop(WidgetTester tester, String label) =>
    tester.getTopLeft(find.text(label)).dy;

void main() {
  const colors = ScalapayColors();

  testWidgets('shows exactly the given texts and nothing else', (tester) async {
    await tester.pumpWidget(_host(_sheet(onClear: () {}, onApply: () {})));
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toSet();
    expect(texts, {
      'Filtri',
      'Fascia di prezzo',
      'Minimo',
      'Massimo',
      'Cancella tutto',
      'Mostra risultati',
    });
  });

  testWidgets('the fields use a numeric keyboard with decimals', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_sheet()));
    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(
        field.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    }
    expect(find.byType(TextField), findsNWidgets(2));
  });

  group('price fields accept only numbers', () {
    for (final index in [0, 1]) {
      final name = index == 0 ? 'min' : 'max';

      testWidgets('$name: letters, spaces and minus are ignored', (
        tester,
      ) async {
        final c = TextEditingController();
        await tester.pumpWidget(
          _host(_sheet(min: index == 0 ? c : null, max: index == 1 ? c : null)),
        );
        final field = find.byType(TextField).at(index);
        await tester.enterText(field, '12');
        for (final bad in ['12a', '12 ', '-12', '12-']) {
          await tester.enterText(field, bad);
          expect(c.text, '12', reason: bad);
        }
      });

      testWidgets('$name: a second separator is ignored', (tester) async {
        final c = TextEditingController();
        await tester.pumpWidget(
          _host(_sheet(min: index == 0 ? c : null, max: index == 1 ? c : null)),
        );
        final field = find.byType(TextField).at(index);
        await tester.enterText(field, '1.5');
        await tester.enterText(field, '1.5.');
        expect(c.text, '1.5');
        await tester.enterText(field, '1.5,');
        expect(c.text, '1.5');
      });

      testWidgets('$name: a comma becomes a period in field and controller', (
        tester,
      ) async {
        final c = TextEditingController();
        await tester.pumpWidget(
          _host(_sheet(min: index == 0 ? c : null, max: index == 1 ? c : null)),
        );
        await tester.enterText(find.byType(TextField).at(index), '12,5');
        expect(c.text, '12.5');
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(index))
              .controller!
              .text,
          '12.5',
        );
      });
    }
  });

  testWidgets('typing updates each controller', (tester) async {
    final min = TextEditingController();
    final max = TextEditingController();
    await tester.pumpWidget(_host(_sheet(min: min, max: max)));
    await tester.enterText(find.byType(TextField).at(0), '150');
    await tester.enterText(find.byType(TextField).at(1), '2000.50');
    expect(min.text, '150');
    expect(max.text, '2000.50');
  });

  testWidgets('preset and cleared values float or reset the label', (
    tester,
  ) async {
    final min = TextEditingController(text: '150');
    final max = TextEditingController();
    await tester.pumpWidget(_host(_sheet(min: min, max: max)));
    expect(find.text('150'), findsOneWidget);
    // The preset field has its label floated above the empty one.
    expect(_labelTop(tester, 'Minimo'), lessThan(_labelTop(tester, 'Massimo')));

    min.clear();
    await tester.pumpAndSettle();
    expect(find.text('150'), findsNothing);
    expect(_labelTop(tester, 'Minimo'), _labelTop(tester, 'Massimo'));
  });

  testWidgets('works without controllers', (tester) async {
    await tester.pumpWidget(_host(_sheet()));
    await tester.enterText(find.byType(TextField).at(0), '12');
    await tester.enterText(find.byType(TextField).at(1), '34');
    expect(find.text('12'), findsOneWidget);
    expect(find.text('34'), findsOneWidget);
  });

  testWidgets('accepts a minimum greater than the maximum without a message', (
    tester,
  ) async {
    final min = TextEditingController();
    final max = TextEditingController();
    await tester.pumpWidget(_host(_sheet(min: min, max: max)));
    await tester.enterText(find.byType(TextField).at(0), '500');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.pump();
    expect(min.text, '500');
    expect(max.text, '100');
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toSet();
    expect(texts.length, 4 + 2); // title, price title, 2 labels, 2 buttons
  });

  testWidgets('a caller-supplied error message is shown once below the fields '
      'in the error style', (tester) async {
    await tester.pumpWidget(
      _host(_sheet(priceError: 'Il minimo supera il massimo')),
    );
    expect(find.text('Il minimo supera il massimo'), findsOneWidget);
    final style = tester
        .widget<Text>(find.text('Il minimo supera il massimo'))
        .style!;
    expect(style.color, colors.error);
  });

  testWidgets('no error message means no message and no reserved space', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_sheet()));
    expect(find.text('Il minimo supera il massimo'), findsNothing);
    final withoutError = tester
        .getSize(find.byType(ScalapayFiltersBottomSheet))
        .height;

    await tester.pumpWidget(_host(_sheet(priceError: '')));
    final withEmptyStringError = tester
        .getSize(find.byType(ScalapayFiltersBottomSheet))
        .height;
    // An empty (non-null) string still reserves a line, unlike null: this
    // proves the height difference below comes from the message itself, not
    // from unrelated layout noise.
    expect(withEmptyStringError, greaterThan(withoutError));
  });

  testWidgets('the footer buttons call their callbacks once', (tester) async {
    var clears = 0;
    var applies = 0;
    await tester.pumpWidget(
      _host(_sheet(onClear: () => clears++, onApply: () => applies++)),
    );
    await tester.tap(find.text('Cancella tutto'));
    expect((clears, applies), (1, 0));
    await tester.tap(find.text('Mostra risultati'));
    expect((clears, applies), (1, 1));
  });

  testWidgets('a button without callback is disabled', (tester) async {
    await tester.pumpWidget(_host(_sheet()));
    for (final label in ['Cancella tutto', 'Mostra risultati']) {
      final button = tester.widget<ScalapayButton>(
        find.widgetWithText(ScalapayButton, label),
      );
      expect(button.onPressed, isNull, reason: label);
      expect(
        tester.widget<Text>(find.text(label)).style!.color,
        colors.textDisabled,
      );
    }
  });

  testWidgets('clear is the tertiary button and apply the primary one', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_sheet(onClear: () {}, onApply: () {})));
    final clear = tester.widget<ScalapayButton>(
      find.widgetWithText(ScalapayButton, 'Cancella tutto'),
    );
    final apply = tester.widget<ScalapayButton>(
      find.widgetWithText(ScalapayButton, 'Mostra risultati'),
    );
    expect(clear.variant, ScalapayButtonVariant.tertiary);
    expect(apply.variant, ScalapayButtonVariant.primary);
  });

  testWidgets('the close button calls onClose once', (tester) async {
    var closes = 0;
    await tester.pumpWidget(_host(_sheet(onClose: () => closes++)));
    await tester.tap(find.byType(ScalapayIcon));
    expect(closes, 1);
  });

  testWidgets('the fields have equal width and fill the card content', (
    tester,
  ) async {
    for (final width in [375.0, 320.0]) {
      await tester.pumpWidget(_host(_sheet(), width: width));
      final first = find.byType(ScalapayTextField).at(0);
      final second = find.byType(ScalapayTextField).at(1);
      expect(tester.getSize(first).width, tester.getSize(second).width);
      // Sheet padding 16 + card padding 16 on each side.
      expect(tester.getTopLeft(first).dx, 32);
      expect(tester.getTopRight(second).dx, width - 32);
      // Dash area: 11px dash with 8 on each side.
      expect(
        tester.getTopLeft(second).dx - tester.getTopRight(first).dx,
        11 + 2 * 8,
      );
    }
  });

  testWidgets('its height follows the content in a tall parent', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_sheet()));
    final height = tester
        .getSize(find.byType(ScalapayFiltersBottomSheet))
        .height;
    expect(height, lessThan(400));
    expect(height, greaterThan(250));
  });
}
