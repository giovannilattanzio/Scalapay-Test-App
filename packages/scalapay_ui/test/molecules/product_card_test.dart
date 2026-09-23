import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

const _imageKey = ValueKey('product-image');
const _image = SizedBox(key: _imageKey, width: 40, height: 40);

Widget _host(
  Widget Function() card, {
  Locale locale = const Locale('en', 'US'),
  double width = 164,
}) => MaterialApp(
  theme: ScalapayTheme.light(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: Builder(
          builder: (context) => Localizations.override(
            context: context,
            locale: locale,
            child: card(),
          ),
        ),
      ),
    ),
  ),
);

ScalapayProductCard _card({
  String name = 'Nike Revolution 6',
  String store = 'Pittarello',
  double price = 85,
  String? currency = '€',
  String? connector,
  int? count,
  double? amount,
  String? label,
}) => ScalapayProductCard(
  image: _image,
  name: name,
  store: store,
  price: price,
  currency: currency,
  priceConnector: connector,
  installmentCount: count,
  installmentAmount: amount,
  installmentLabel: label,
);

TextStyle _styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

void main() {
  const colors = ScalapayColors();

  group('content', () {
    testWidgets('shows the given image and texts, and nothing else', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          () =>
              _card(connector: 'or', count: 3, amount: 23.33, label: 'rate da'),
        ),
      );
      expect(find.byKey(_imageKey), findsOneWidget);
      expect(find.text('Nike Revolution 6'), findsOneWidget);
      expect(find.text('Pittarello'), findsOneWidget);
      expect(find.text('€85.00 or'), findsOneWidget);
      expect(find.text('3 rate da €23.33'), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(4));
    });

    testWidgets('uses the design tokens for colors', (tester) async {
      await tester.pumpWidget(
        _host(
          () =>
              _card(connector: 'or', count: 3, amount: 23.33, label: 'rate da'),
        ),
      );
      expect(_styleOf(tester, 'Nike Revolution 6').color, colors.textPrimary);
      expect(_styleOf(tester, 'Pittarello').color, colors.textStoreName);
      expect(_styleOf(tester, '€85.00 or').color, colors.textSecondary);
      expect(_styleOf(tester, '3 rate da €23.33').color, colors.primary);
    });
  });

  group('money', () {
    testWidgets('uses the decimal separator of an Italian locale', (
      tester,
    ) async {
      await tester.pumpWidget(_host(() => _card(), locale: const Locale('it')));
      expect(find.textContaining('85,00'), findsOneWidget);
      expect(find.textContaining('€'), findsOneWidget);
    });

    testWidgets('uses the decimal separator of an English locale', (
      tester,
    ) async {
      await tester.pumpWidget(_host(() => _card()));
      expect(find.text('€85.00'), findsOneWidget);
    });

    testWidgets('currency applies to price and installment amount', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(() => _card(currency: '\$', count: 2, amount: 42.5, label: 'x')),
      );
      expect(find.text('\$85.00'), findsOneWidget);
      expect(find.text('2 x \$42.50'), findsOneWidget);
    });

    testWidgets('without currency amounts are plain numbers', (tester) async {
      await tester.pumpWidget(
        _host(
          () =>
              _card(currency: null, count: 3, amount: 23.33, label: 'rate da'),
        ),
      );
      expect(find.text('85.00'), findsOneWidget);
      expect(find.text('3 rate da 23.33'), findsOneWidget);
      expect(find.textContaining('€'), findsNothing);
    });
  });

  group('installments', () {
    testWidgets('line is count, wording, amount in that order', (tester) async {
      await tester.pumpWidget(
        _host(() => _card(count: 3, amount: 23.33, label: 'rate da')),
      );
      expect(find.text('3 rate da €23.33'), findsOneWidget);
    });

    testWidgets('without installments there is no line, connector or gap', (
      tester,
    ) async {
      await tester.pumpWidget(_host(() => _card(connector: 'or')));
      final without = tester.getSize(find.byType(ScalapayProductCard)).height;
      expect(find.text('€85.00'), findsOneWidget);
      expect(find.textContaining('or'), findsNothing);
      expect(find.byType(Text), findsNWidgets(3));

      await tester.pumpWidget(
        _host(() => _card(count: 3, amount: 23.33, label: 'rate da')),
      );
      final withLine = tester.getSize(find.byType(ScalapayProductCard)).height;
      expect(withLine, greaterThan(without));

      // The card ends after the price line plus the bottom text padding.
      await tester.pumpWidget(_host(() => _card()));
      expect(tester.getSize(find.byType(ScalapayProductCard)).height, without);
      final priceBottom = tester.getBottomLeft(find.text('€85.00')).dy;
      final cardBottom = tester
          .getBottomLeft(find.byType(ScalapayProductCard))
          .dy;
      final bottomPadding = const ScalapaySpacing().xs * 1.5;
      expect(cardBottom, priceBottom + bottomPadding);
    });

    testWidgets('a lone installment value is rejected', (tester) async {
      expect(() => _card(count: 3), throwsAssertionError);
      expect(() => _card(amount: 23.33, label: 'x'), throwsAssertionError);
    });

    testWidgets('count and amount without wording are rejected', (
      tester,
    ) async {
      expect(() => _card(count: 3, amount: 23.33), throwsAssertionError);
    });

    testWidgets('the line wraps when it does not fit', (tester) async {
      await tester.pumpWidget(
        _host(
          () => _card(
            count: 12,
            amount: 1234.56,
            label: 'monthly installments of',
          ),
        ),
      );
      final size = tester.getSize(
        find.textContaining('monthly installments of'),
      );
      expect(size.height, greaterThan(21));
    });
  });

  group('price connector', () {
    testWidgets('is shown after the price when installments are shown', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          () => _card(
            connector: 'oppure',
            count: 3,
            amount: 23.33,
            label: 'rate da',
          ),
        ),
      );
      expect(find.text('€85.00 oppure'), findsOneWidget);
    });

    testWidgets('is not shown without installments', (tester) async {
      await tester.pumpWidget(_host(() => _card(connector: 'oppure')));
      expect(find.text('€85.00'), findsOneWidget);
      expect(find.textContaining('oppure'), findsNothing);
    });
  });

  group('layout', () {
    testWidgets('a long name is cut at two lines with an ellipsis', (
      tester,
    ) async {
      const long =
          'Nike Revolution 6 Next Nature Triple Black Running Shoes Limited Edition';
      await tester.pumpWidget(_host(() => _card(name: long)));
      final text = tester.widget<Text>(find.text(long));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(tester.getSize(find.text(long)).height, lessThanOrEqualTo(40));
    });

    testWidgets('the image area keeps its proportion at any width', (
      tester,
    ) async {
      for (final width in [164.0, 200.0, 320.0]) {
        await tester.pumpWidget(_host(() => _card(), width: width));
        final area = tester.getSize(find.byType(AspectRatio));
        expect(area.width, width);
        expect(area.width / area.height, closeTo(164 / 195, 0.001));
      }
    });

    testWidgets(
      'the image sits in a clipped surface area with the image radius',
      (tester) async {
        await tester.pumpWidget(_host(() => _card()));
        final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
        expect(
          clip.borderRadius,
          BorderRadius.circular(const ScalapayRadius().image),
        );
        final fill = tester.widget<ColoredBox>(
          find.descendant(
            of: find.byType(ClipRRect),
            matching: find.byType(ColoredBox),
          ),
        );
        expect(fill.color, colors.surface);
        // The image is centered in the area.
        final area = tester.getCenter(find.byType(ClipRRect));
        expect(tester.getCenter(find.byKey(_imageKey)), area);
      },
    );

    testWidgets('two cards in equal columns fill their column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ScalapayTheme.light(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _card()),
                  const SizedBox(width: 16),
                  Expanded(child: _card(name: 'Other')),
                ],
              ),
            ),
          ),
        ),
      );
      final sizes = tester
          .widgetList(find.byType(ScalapayProductCard))
          .map((w) => tester.getSize(find.byWidget(w)).width)
          .toList();
      expect(sizes[0], sizes[1]);
      expect(sizes[0], greaterThan(300));
    });
  });

  group('accessibility', () {
    testWidgets(
      'the card is one semantics node with the rendered lines in order, '
      'and the image is not announced',
      (tester) async {
        final handle = tester.ensureSemantics();
        final money = NumberFormat.currency(
          locale: 'it',
          symbol: '€',
          decimalDigits: 2,
        );
        final priceLine = money.format(85);
        final installmentsLine = '3 rate da ${money.format(28.33)}';
        final expectedLabel = [
          'Sneaker',
          'Nike',
          priceLine,
          installmentsLine,
        ].join('\n');

        await tester.pumpWidget(
          _host(
            () => ScalapayProductCard(
              image: const Semantics.fromProperties(
                properties: SemanticsProperties(label: 'foto', image: true),
                child: SizedBox(width: 40, height: 40),
              ),
              name: 'Sneaker',
              store: 'Nike',
              price: 85,
              currency: '€',
              installmentCount: 3,
              installmentAmount: 28.33,
              installmentLabel: 'rate da',
            ),
            locale: const Locale('it'),
          ),
        );

        final semantics = tester.getSemantics(find.byType(ScalapayProductCard));
        expect(semantics.label, expectedLabel);
        expect(semantics.label, contains('Sneaker'));
        expect(semantics.label, contains('Nike'));
        expect(semantics.label, contains(priceLine));
        expect(semantics.label, contains(installmentsLine));
        // The image (and anything else inside) adds no node of its own.
        expect(semantics.childrenCount, 0);
        expect(find.bySemanticsLabel('foto'), findsNothing);

        handle.dispose();
      },
    );

    testWidgets('at a large text scale it grows without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ScalapayTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 164, child: _card()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('meets tap target guidelines (no interactive element inside)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(() => Padding(padding: const EdgeInsets.all(24), child: _card())),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });
  });
}
