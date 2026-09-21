import 'dart:convert';
import 'dart:io';

import 'package:catalog_api/catalog_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/data/data.dart';

const _fixturePath = 'test/fixtures/product_search_nike.json';

const _expectedIdsInOrder = [
  '569515057',
  '897641638',
  '897641641',
  '964947151',
  '923509399',
  '964947139',
];
const _expectedSellingPricesInOrder = [6.0, 8.0, 8.0, 3.4, 3.7, 3.7];
const _expectedMerchantsInOrder = [
  'Farmacia Loreto',
  'Erreà Play',
  'Erreà Play',
  'Parfimo',
  'Parfimo',
  'Parfimo',
];

Map<String, dynamic> _decodeFixtureRaw() {
  final raw = File(_fixturePath).readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

ProductSearchResponse _decodeFixture() =>
    ProductSearchResponse.fromJson(_decodeFixtureRaw());

ProductDocument _document({String id = '1', bool isMerchantCard = false}) =>
    ProductDocument(
      id: id,
      title: 'A product',
      brand: 'A brand',
      merchant: 'A store',
      sellingPrice: 10,
      listPrice: 12,
      image: 'https://example.com/image.png',
      isMerchantCard: isMerchantCard,
    );

void main() {
  group('toEntity', () {
    test('maps a document field-to-field onto the domain entity', () {
      final document = _document();

      final product = toEntity(document);

      expect(product.id, document.id);
      expect(product.name, document.title);
      expect(product.store, document.merchant);
      expect(product.brand, document.brand);
      expect(product.imageUrl, document.image);
      expect(product.sellingPrice, document.sellingPrice);
      expect(product.listPrice, document.listPrice);
    });

    test(
      'a document carrying isMerchantCard: true maps as an ordinary product',
      () {
        final document = _document(isMerchantCard: true);

        final product = toEntity(document);

        expect(product.id, document.id);
        expect(product.name, document.title);
        expect(product.store, document.merchant);
      },
    );
  });

  group('toSearchResult', () {
    test('flattens groupedHits in order, carrying page through', () {
      final response = _decodeFixture();

      final result = toSearchResult(response);

      expect(result.page, response.page);
      expect(result.products.map((p) => p.id).toList(), _expectedIdsInOrder);
      expect(
        result.products.map((p) => p.sellingPrice).toList(),
        _expectedSellingPricesInOrder,
      );
      expect(
        result.products.map((p) => p.store).toList(),
        _expectedMerchantsInOrder,
      );
    });

    test('an empty groupedHits maps to an empty product list', () {
      final response = ProductSearchResponse(
        page: 1,
        found: 0,
        groupedHits: const [],
      );

      final result = toSearchResult(response);

      expect(result.products, isEmpty);
      expect(result.page, 1);
    });

    test('a document missing a required field fails to parse before reaching '
        'the mapper, so the whole response is unreadable', () {
      // ProductSearchResponse.fromJson decodes every document eagerly
      // (checked: true), so a malformed document never becomes a
      // ProductSearchResponse in the first place — there is no
      // ProductSearchResponse to hand to toSearchResult in this case.
      // The real failure path is exercised at the repository level,
      // where this throw surfaces as a SerializationFailure.
      final json = _decodeFixtureRaw();
      final groupedHits = (json['grouped_hits'] as List)
          .cast<Map<String, dynamic>>();
      final firstDocument =
          (groupedHits.first['hits'] as List)
                  .cast<Map<String, dynamic>>()
                  .first['document']
              as Map<String, dynamic>;
      firstDocument.remove('title');

      expect(() => ProductSearchResponse.fromJson(json), throwsA(anything));
    });
  });
}
