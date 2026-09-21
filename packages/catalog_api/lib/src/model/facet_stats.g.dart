// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facet_stats.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FacetStatsCWProxy {
  FacetStats min(double? min);

  FacetStats max(double? max);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FacetStats(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FacetStats(...).copyWith(id: 12, name: "My name")
  /// ```
  FacetStats call({double? min, double? max});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfFacetStats.copyWith(...)` or call `instanceOfFacetStats.copyWith.fieldName(value)` for a single field.
class _$FacetStatsCWProxyImpl implements _$FacetStatsCWProxy {
  const _$FacetStatsCWProxyImpl(this._value);

  final FacetStats _value;

  @override
  FacetStats min(double? min) => call(min: min);

  @override
  FacetStats max(double? max) => call(max: max);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FacetStats(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FacetStats(...).copyWith(id: 12, name: "My name")
  /// ```
  FacetStats call({
    Object? min = const $CopyWithPlaceholder(),
    Object? max = const $CopyWithPlaceholder(),
  }) {
    return FacetStats(
      min: min == const $CopyWithPlaceholder()
          ? _value.min
          // ignore: cast_nullable_to_non_nullable
          : min as double?,
      max: max == const $CopyWithPlaceholder()
          ? _value.max
          // ignore: cast_nullable_to_non_nullable
          : max as double?,
    );
  }
}

extension $FacetStatsCopyWith on FacetStats {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfFacetStats.copyWith(...)` or `instanceOfFacetStats.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FacetStatsCWProxy get copyWith => _$FacetStatsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacetStats _$FacetStatsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FacetStats', json, ($checkedConvert) {
      final val = FacetStats(
        min: $checkedConvert('min', (v) => (v as num?)?.toDouble()),
        max: $checkedConvert('max', (v) => (v as num?)?.toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$FacetStatsToJson(FacetStats instance) =>
    <String, dynamic>{'min': ?instance.min, 'max': ?instance.max};
