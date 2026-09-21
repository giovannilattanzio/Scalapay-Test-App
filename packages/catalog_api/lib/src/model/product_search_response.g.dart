// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_search_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProductSearchResponseCWProxy {
  ProductSearchResponse page(int page);

  ProductSearchResponse found(int found);

  ProductSearchResponse groupedHits(List<GroupedHit> groupedHits);

  ProductSearchResponse facetCounts(List<FacetCount>? facetCounts);

  ProductSearchResponse merchantDetectedFromQuery(
    DetectedMerchant? merchantDetectedFromQuery,
  );

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProductSearchResponse(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProductSearchResponse(...).copyWith(id: 12, name: "My name")
  /// ```
  ProductSearchResponse call({
    int page,
    int found,
    List<GroupedHit> groupedHits,
    List<FacetCount>? facetCounts,
    DetectedMerchant? merchantDetectedFromQuery,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProductSearchResponse.copyWith(...)` or call `instanceOfProductSearchResponse.copyWith.fieldName(value)` for a single field.
class _$ProductSearchResponseCWProxyImpl
    implements _$ProductSearchResponseCWProxy {
  const _$ProductSearchResponseCWProxyImpl(this._value);

  final ProductSearchResponse _value;

  @override
  ProductSearchResponse page(int page) => call(page: page);

  @override
  ProductSearchResponse found(int found) => call(found: found);

  @override
  ProductSearchResponse groupedHits(List<GroupedHit> groupedHits) =>
      call(groupedHits: groupedHits);

  @override
  ProductSearchResponse facetCounts(List<FacetCount>? facetCounts) =>
      call(facetCounts: facetCounts);

  @override
  ProductSearchResponse merchantDetectedFromQuery(
    DetectedMerchant? merchantDetectedFromQuery,
  ) => call(merchantDetectedFromQuery: merchantDetectedFromQuery);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProductSearchResponse(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProductSearchResponse(...).copyWith(id: 12, name: "My name")
  /// ```
  ProductSearchResponse call({
    Object? page = const $CopyWithPlaceholder(),
    Object? found = const $CopyWithPlaceholder(),
    Object? groupedHits = const $CopyWithPlaceholder(),
    Object? facetCounts = const $CopyWithPlaceholder(),
    Object? merchantDetectedFromQuery = const $CopyWithPlaceholder(),
  }) {
    return ProductSearchResponse(
      page: page == const $CopyWithPlaceholder() || page == null
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as int,
      found: found == const $CopyWithPlaceholder() || found == null
          ? _value.found
          // ignore: cast_nullable_to_non_nullable
          : found as int,
      groupedHits:
          groupedHits == const $CopyWithPlaceholder() || groupedHits == null
          ? _value.groupedHits
          // ignore: cast_nullable_to_non_nullable
          : groupedHits as List<GroupedHit>,
      facetCounts: facetCounts == const $CopyWithPlaceholder()
          ? _value.facetCounts
          // ignore: cast_nullable_to_non_nullable
          : facetCounts as List<FacetCount>?,
      merchantDetectedFromQuery:
          merchantDetectedFromQuery == const $CopyWithPlaceholder()
          ? _value.merchantDetectedFromQuery
          // ignore: cast_nullable_to_non_nullable
          : merchantDetectedFromQuery as DetectedMerchant?,
    );
  }
}

extension $ProductSearchResponseCopyWith on ProductSearchResponse {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProductSearchResponse.copyWith(...)` or `instanceOfProductSearchResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProductSearchResponseCWProxy get copyWith =>
      _$ProductSearchResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductSearchResponse _$ProductSearchResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ProductSearchResponse',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['page', 'found', 'grouped_hits']);
    final val = ProductSearchResponse(
      page: $checkedConvert('page', (v) => (v as num).toInt()),
      found: $checkedConvert('found', (v) => (v as num).toInt()),
      groupedHits: $checkedConvert(
        'grouped_hits',
        (v) => (v as List<dynamic>)
            .map((e) => GroupedHit.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      facetCounts: $checkedConvert(
        'facet_counts',
        (v) => (v as List<dynamic>?)
            ?.map((e) => FacetCount.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      merchantDetectedFromQuery: $checkedConvert(
        'merchantDetectedFromQuery',
        (v) => v == null
            ? null
            : DetectedMerchant.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'groupedHits': 'grouped_hits',
    'facetCounts': 'facet_counts',
  },
);

Map<String, dynamic> _$ProductSearchResponseToJson(
  ProductSearchResponse instance,
) => <String, dynamic>{
  'page': instance.page,
  'found': instance.found,
  'grouped_hits': instance.groupedHits.map((e) => e.toJson()).toList(),
  'facet_counts': ?instance.facetCounts?.map((e) => e.toJson()).toList(),
  'merchantDetectedFromQuery': ?instance.merchantDetectedFromQuery?.toJson(),
};
