import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

void main() {
  group('foundations', () {
    test('primary color matches the design', () {
      expect(const ScalapayColors().primary, const Color(0xFF5666F0));
    });

    test('grayscale values match the design', () {
      const c = ScalapayColors();
      expect(c.background, const Color(0xFFFFFFFF));
      expect(c.surface, const Color(0xFFF6F7FB));
      expect(c.border, const Color(0xFFEFF1F5));
      expect(c.textSecondary, const Color(0xFF8A8A8D));
      expect(c.textPrimary, const Color(0xFF272727));
    });

    test('duplicated Figma values collapse into one token', () {
      final values = const ScalapayColors().entries.values.toList();
      expect(values.where((v) => v == const Color(0xFFF6F7FB)), hasLength(1));
      expect(values.where((v) => v == const Color(0xFFEFF1F5)), hasLength(1));
    });

    test('spacing and radius', () {
      expect(const ScalapaySpacing().xs, 8);
      expect(const ScalapaySpacing().s, 16);
      expect(const ScalapayRadius().child, 10);
    });

    test('image radius token', () {
      expect(const ScalapayRadius().image, 20);
      expect(const ScalapayRadius().entries['image'], 20);
    });

    test('card and sheet radius tokens', () {
      const r = ScalapayRadius();
      expect(r.card, 20);
      expect(r.sheet, 20);
      expect(r.entries['card'], 20);
      expect(r.entries['sheet'], 20);
      // Same value, separate tokens: each can change alone.
      const changed = ScalapayRadius(card: 16);
      expect(changed.card, 16);
      expect(changed.sheet, 20);
      expect(changed.image, 20);
    });

    test('store name color token', () {
      const c = ScalapayColors();
      expect(c.textStoreName, const Color(0xFF3A4045));
      expect(c.entries['textStoreName'], const Color(0xFF3A4045));
      final lerped = c.lerp(
        const ScalapayColors(textStoreName: Color(0xFF000000)),
        1,
      );
      expect(lerped.textStoreName, const Color(0xFF000000));
    });

    test('H2 style metrics', () {
      final h2 = const ScalapayTypography().h2;
      expect(h2.fontSize, 25);
      expect(h2.fontWeight, FontWeight.w600);
      expect(h2.fontSize! * h2.height!, closeTo(30, 0.001));
    });

    test('P2 style', () {
      final p2 = const ScalapayTypography().p2;
      expect(p2.fontSize, 14);
      expect(p2.fontWeight, FontWeight.w600);
      expect(p2.fontSize! * p2.height!, closeTo(21, 0.001));
    });

    test('P5 in two weights', () {
      const typography = ScalapayTypography();
      final p5 = typography.p5;
      final p5Semibold = typography.p5Semibold;
      expect(p5.fontSize, 11);
      expect(p5Semibold.fontSize, 11);
      expect(p5.fontSize! * p5.height!, closeTo(16.5, 0.001));
      expect(p5Semibold.fontSize! * p5Semibold.height!, closeTo(16.5, 0.001));
      expect(p5.fontWeight, FontWeight.w500);
      expect(p5Semibold.fontWeight, FontWeight.w600);
    });

    test('every text style uses Poppins from the package', () {
      for (final style in const ScalapayTypography().entries.values) {
        expect(style.fontFamily, 'packages/scalapay_ui/Poppins');
      }
    });
  });

  group('theme', () {
    testWidgets('tokens are readable from any build context', (tester) async {
      late ScalapayTokens tokens;
      await tester.pumpWidget(
        MaterialApp(
          theme: ScalapayTheme.light(),
          home: Builder(
            builder: (context) {
              tokens = context.tokens;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tokens.colors.primary, const Color(0xFF5666F0));
      expect(tokens.spacing.s, 16);
    });

    testWidgets('missing theme fails explicitly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              context.tokens;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());
    });

    test('copyWith and lerp keep the extension consistent', () {
      const a = ScalapayTokens();
      final b = a.copyWith(
        colors: const ScalapayColors(primary: Color(0xFF000000)),
      );
      expect(a.lerp(b, 1).colors.primary, const Color(0xFF000000));
      expect(a.lerp(null, 0.5), a);
    });
  });
}
