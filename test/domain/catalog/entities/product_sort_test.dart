import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/domain/domain.dart';

void main() {
  group('ProductSort', () {
    test('queryValue for the three named combinations', () {
      expect(ProductSort.priceAsc.queryValue, 'selling_price:asc');
      expect(ProductSort.priceDesc.queryValue, 'selling_price:desc');
      expect(ProductSort.relevance.queryValue, '_text_match:desc');
    });

    test(
      'sheetOptions holds relevance first, then the two price combinations',
      () {
        expect(ProductSort.sheetOptions.length, 3);
        expect(ProductSort.sheetOptions, [
          ProductSort.relevance,
          ProductSort.priceAsc,
          ProductSort.priceDesc,
        ]);
        // Name ordering has no ProductSortType at all; relevance is
        // deliberately present so the default stays reachable.
        expect(
          ProductSort.sheetOptions.every(
            (sort) =>
                sort.type == ProductSortType.relevance ||
                sort.type == ProductSortType.sellingPrice,
          ),
          isTrue,
        );
      },
    );
  });
}
