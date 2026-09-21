// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facet_count.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FacetCountCWProxy {
  FacetCount fieldName(String? fieldName);

  FacetCount counts(List<FacetValue>? counts);

  FacetCount stats(FacetStats? stats);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FacetCount(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FacetCount(...).copyWith(id: 12, name: "My name")
  /// ```
  FacetCount call({
    String? fieldName,
    List<FacetValue>? counts,
    FacetStats? stats,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfFacetCount.copyWith(...)` or call `instanceOfFacetCount.copyWith.fieldName(value)` for a single field.
class _$FacetCountCWProxyImpl implements _$FacetCountCWProxy {
  const _$FacetCountCWProxyImpl(this._value);

  final FacetCount _value;

  @override
  FacetCount fieldName(String? fieldName) => call(fieldName: fieldName);

  @override
  FacetCount counts(List<FacetValue>? counts) => call(counts: counts);

  @override
  FacetCount stats(FacetStats? stats) => call(stats: stats);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FacetCount(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FacetCount(...).copyWith(id: 12, name: "My name")
  /// ```
  FacetCount call({
    Object? fieldName = const $CopyWithPlaceholder(),
    Object? counts = const $CopyWithPlaceholder(),
    Object? stats = const $CopyWithPlaceholder(),
  }) {
    return FacetCount(
      fieldName: fieldName == const $CopyWithPlaceholder()
          ? _value.fieldName
          // ignore: cast_nullable_to_non_nullable
          : fieldName as String?,
      counts: counts == const $CopyWithPlaceholder()
          ? _value.counts
          // ignore: cast_nullable_to_non_nullable
          : counts as List<FacetValue>?,
      stats: stats == const $CopyWithPlaceholder()
          ? _value.stats
          // ignore: cast_nullable_to_non_nullable
          : stats as FacetStats?,
    );
  }
}

extension $FacetCountCopyWith on FacetCount {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfFacetCount.copyWith(...)` or `instanceOfFacetCount.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FacetCountCWProxy get copyWith => _$FacetCountCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacetCount _$FacetCountFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FacetCount', json, ($checkedConvert) {
      final val = FacetCount(
        fieldName: $checkedConvert('field_name', (v) => v as String?),
        counts: $checkedConvert(
          'counts',
          (v) => (v as List<dynamic>?)
              ?.map((e) => FacetValue.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        stats: $checkedConvert(
          'stats',
          (v) =>
              v == null ? null : FacetStats.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'fieldName': 'field_name'});

Map<String, dynamic> _$FacetCountToJson(FacetCount instance) =>
    <String, dynamic>{
      'field_name': ?instance.fieldName,
      'counts': ?instance.counts?.map((e) => e.toJson()).toList(),
      'stats': ?instance.stats?.toJson(),
    };
