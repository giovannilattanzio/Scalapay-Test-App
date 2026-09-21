// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facet_value.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FacetValueCWProxy {
  FacetValue count(int? count);

  FacetValue highlighted(String? highlighted);

  FacetValue value(String? value);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FacetValue(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FacetValue(...).copyWith(id: 12, name: "My name")
  /// ```
  FacetValue call({int? count, String? highlighted, String? value});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfFacetValue.copyWith(...)` or call `instanceOfFacetValue.copyWith.fieldName(value)` for a single field.
class _$FacetValueCWProxyImpl implements _$FacetValueCWProxy {
  const _$FacetValueCWProxyImpl(this._value);

  final FacetValue _value;

  @override
  FacetValue count(int? count) => call(count: count);

  @override
  FacetValue highlighted(String? highlighted) => call(highlighted: highlighted);

  @override
  FacetValue value(String? value) => call(value: value);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FacetValue(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FacetValue(...).copyWith(id: 12, name: "My name")
  /// ```
  FacetValue call({
    Object? count = const $CopyWithPlaceholder(),
    Object? highlighted = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
  }) {
    return FacetValue(
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int?,
      highlighted: highlighted == const $CopyWithPlaceholder()
          ? _value.highlighted
          // ignore: cast_nullable_to_non_nullable
          : highlighted as String?,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as String?,
    );
  }
}

extension $FacetValueCopyWith on FacetValue {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfFacetValue.copyWith(...)` or `instanceOfFacetValue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FacetValueCWProxy get copyWith => _$FacetValueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacetValue _$FacetValueFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FacetValue', json, ($checkedConvert) {
      final val = FacetValue(
        count: $checkedConvert('count', (v) => (v as num?)?.toInt()),
        highlighted: $checkedConvert('highlighted', (v) => v as String?),
        value: $checkedConvert('value', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$FacetValueToJson(FacetValue instance) =>
    <String, dynamic>{
      'count': ?instance.count,
      'highlighted': ?instance.highlighted,
      'value': ?instance.value,
    };
