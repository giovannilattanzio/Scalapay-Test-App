import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

Product _product(String id) => Product(
  id: id,
  name: id,
  store: 'store',
  brand: 'brand',
  imageUrl: 'url',
  sellingPrice: 10,
  listPrice: 10,
);

List<Product> _page(int pageIndex, {int perPage = 30}) =>
    List.generate(perPage, (i) => _product('p${pageIndex * perPage + i}'));

void main() {
  group('ProductPageAccumulator.append', () {
    test(
      'ten distinct pages then a repeat of page 1 accumulates 300 products '
      'with no duplicates and reaches the end without appending anything',
      () {
        var accumulator = const ProductPageAccumulator();

        for (var i = 0; i < 10; i++) {
          accumulator = accumulator.append(_page(i), perPage: 30);
        }

        expect(accumulator.products.length, 300);
        expect(accumulator.seenIds.length, 300);
        expect(accumulator.hasReachedEnd, isFalse);

        final productsBeforeRepeat = accumulator.products;
        final repeated = accumulator.append(_page(0), perPage: 30);

        expect(repeated.hasReachedEnd, isTrue);
        expect(repeated.products, productsBeforeRepeat);
        expect(repeated.products.length, 300);
        expect(repeated.nextPage, accumulator.nextPage);
      },
    );

    test('a partially overlapping page contributes only its new products and '
        'does not reach the end', () {
      final firstPage = _page(0, perPage: 30);
      final accumulator = const ProductPageAccumulator().append(
        firstPage,
        perPage: 30,
      );

      final overlapping = [
        ...firstPage.sublist(0, 18),
        ..._page(1, perPage: 30).sublist(0, 12),
      ];

      final result = accumulator.append(overlapping, perPage: 30);

      expect(result.products.length, 30 + 12);
      expect(result.hasReachedEnd, isFalse);
      expect(result.nextPage, accumulator.nextPage + 1);
    });

    test('a page shorter than perPage appends and reaches the end', () {
      final shortPage = _page(0, perPage: 12);

      final result = const ProductPageAccumulator().append(
        shortPage,
        perPage: 30,
      );

      expect(result.products, shortPage);
      expect(result.hasReachedEnd, isTrue);
    });

    test('a service that never repeats is stopped by maxPages', () {
      var accumulator = const ProductPageAccumulator();

      for (var i = 0; i < ProductPageAccumulator.maxPages; i++) {
        accumulator = accumulator.append(_page(i), perPage: 30);
      }

      expect(accumulator.hasReachedEnd, isTrue);
      expect(accumulator.nextPage, ProductPageAccumulator.maxPages + 1);
      expect(accumulator.products.length, ProductPageAccumulator.maxPages * 30);
    });

    test('nextPage advances only when something was appended', () {
      final seeded = ProductPageAccumulator(
        products: const [],
        seenIds: const {'already-seen'},
        nextPage: 5,
      );

      final stillSame = seeded.append([_product('already-seen')], perPage: 30);
      expect(stillSame.nextPage, 5);
      expect(stillSame.hasReachedEnd, isTrue);

      final withNew = seeded.append([_product('brand-new')], perPage: 30);
      expect(withNew.nextPage, 6);
    });
  });
}
