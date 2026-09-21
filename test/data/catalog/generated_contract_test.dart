// Guards packages/catalog_api against drift from the reverse-engineered
// openapi/catalog-api.yaml: the catalog service publishes no API description,
// so if a captured field disappears or changes type, this test fails offline
// instead of the app failing at runtime.

import 'dart:convert';
import 'dart:io';

import 'package:catalog_api/catalog_api.dart';
import 'package:flutter_test/flutter_test.dart';

const _fixturePath = 'test/fixtures/product_search_nike.json';
const _expectedMerchantsInOrder = [
  'Farmacia Loreto',
  'Erreà Play',
  'Erreà Play',
  'Parfimo',
  'Parfimo',
  'Parfimo',
];
const _expectedSellingPricesInOrder = [6.0, 8.0, 8.0, 3.4, 3.7, 3.7];

Map<String, dynamic> _decodeFixture() {
  final raw = File(_fixturePath).readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  group('ProductSearchResponse contract', () {
    test('parses the captured fixture with no exception', () {
      final response = ProductSearchResponse.fromJson(_decodeFixture());

      expect(response.page, 1);
      expect(response.found, 6);
      expect(response.groupedHits.length, 6);
      for (final group in response.groupedHits) {
        expect(group.hits.length, 1);
      }
    });

    test('selling_price arrives as double for both integer and decimal JSON values', () {
      final response = ProductSearchResponse.fromJson(_decodeFixture());
      final prices = response.groupedHits
          .map((g) => g.hits.single.document.sellingPrice)
          .toList();

      // The central point of this whole test: `type: number, format: double`
      // in the OpenAPI document is what forces a bare JSON integer like `6`
      // to decode as a Dart `double` rather than an `int`, so callers never
      // have to handle two runtime types for the same field.
      expect(prices, _expectedSellingPricesInOrder);
      for (final price in prices) {
        expect(price, isA<double>());
      }
    });

    test('merchant names match the captured values, in order', () {
      final response = ProductSearchResponse.fromJson(_decodeFixture());
      final merchants = response.groupedHits
          .map((g) => g.hits.single.document.merchant)
          .toList();

      expect(merchants, _expectedMerchantsInOrder);
    });

    test('merchantDetectedFromQuery is parsed', () {
      final response = ProductSearchResponse.fromJson(_decodeFixture());

      expect(response.merchantDetectedFromQuery?.name, 'Nike');
    });

    test(
      'facet_counts field names are in order and only selling_price has stats',
      () {
        final response = ProductSearchResponse.fromJson(_decodeFixture());
        final facets = response.facetCounts!;

        expect(facets.map((f) => f.fieldName).toList(), [
          'category',
          'merchant',
          'brand',
          'selling_price',
        ]);
        expect(facets[0].stats?.min, isNull);
        expect(facets[0].stats?.max, isNull);
        expect(facets[1].stats?.min, isNull);
        expect(facets[2].stats?.min, isNull);
        expect(facets[3].stats?.min, isNotNull);
        expect(facets[3].stats?.max, isNotNull);
      },
    );

    test('a document carrying isMerchantCard parses as a complete, ordinary product', () {
      // No captured document happens to carry isMerchantCard, so this variant
      // is built inline rather than hitting the network to obtain one.
      final json = _decodeFixture();
      final groupedHits = (json['grouped_hits'] as List)
          .cast<Map<String, dynamic>>();
      final firstGroup =
          jsonDecode(jsonEncode(groupedHits.first)) as Map<String, dynamic>;
      final document =
          (firstGroup['hits'] as List)
                  .cast<Map<String, dynamic>>()
                  .first['document']
              as Map<String, dynamic>;
      document['isMerchantCard'] = true;
      document['merchantToken'] = 'CM3YJ8B0T';

      json['grouped_hits'] = [firstGroup];
      final response = ProductSearchResponse.fromJson(json);
      final product = response.groupedHits.single.hits.single.document;

      expect(product.isMerchantCard, true);
      expect(product.merchantToken, 'CM3YJ8B0T');
      expect(product.title, isNotEmpty);
      expect(product.brand, isNotNull);
      expect(product.merchant, isNotEmpty);
      expect(product.image, isNotEmpty);
      expect(product.sellingPrice, isNotNull);
      expect(product.listPrice, isNotNull);
    });

    test('a response without merchantDetectedFromQuery and with empty facet stats still parses', () {
      // Both variants come from the wire: the field is nullable/optional and
      // stats can be an empty object, per the captured category/merchant/brand
      // facets. Built inline, deep-copied from the fixture so tests don't share
      // mutable state.
      final json = _decodeFixture();
      json.remove('merchantDetectedFromQuery');
      final facetCounts = (json['facet_counts'] as List)
          .cast<Map<String, dynamic>>();
      for (final facet in facetCounts) {
        facet['stats'] = <String, dynamic>{};
      }

      final response = ProductSearchResponse.fromJson(json);

      expect(response.merchantDetectedFromQuery, isNull);
      expect(response.groupedHits.length, 6);
      expect(
        response.groupedHits
            .map((g) => g.hits.single.document.merchant)
            .toList(),
        _expectedMerchantsInOrder,
      );
    });

    test(
      'merchantDetectedFromQuery present explicitly as JSON null still parses',
      () {
        // The OpenAPI document marks the field nullable, distinct from absent:
        // both spellings must decode without throwing.
        final json = _decodeFixture();
        json['merchantDetectedFromQuery'] = null;

        final response = ProductSearchResponse.fromJson(json);

        expect(response.merchantDetectedFromQuery, isNull);
      },
    );
  });
}
