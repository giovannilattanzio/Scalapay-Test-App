import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

void main() {
  group('PriceRange', () {
    test('none is empty', () {
      expect(PriceRange.none.isEmpty, isTrue);
    });

    test('isInverted is true when min is greater than max', () {
      const range = PriceRange(min: 200, max: 100);
      expect(range.isInverted, isTrue);
    });

    test('isInverted is false when min is lower than max', () {
      const range = PriceRange(min: 100, max: 200);
      expect(range.isInverted, isFalse);
    });

    test('isInverted is false when either bound is null', () {
      expect(const PriceRange(min: 100).isInverted, isFalse);
      expect(const PriceRange(max: 100).isInverted, isFalse);
      expect(PriceRange.none.isInverted, isFalse);
    });
  });
}
