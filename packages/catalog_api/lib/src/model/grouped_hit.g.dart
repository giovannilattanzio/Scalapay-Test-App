// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grouped_hit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GroupedHitCWProxy {
  GroupedHit hits(List<Hit> hits);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GroupedHit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GroupedHit(...).copyWith(id: 12, name: "My name")
  /// ```
  GroupedHit call({List<Hit> hits});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfGroupedHit.copyWith(...)` or call `instanceOfGroupedHit.copyWith.fieldName(value)` for a single field.
class _$GroupedHitCWProxyImpl implements _$GroupedHitCWProxy {
  const _$GroupedHitCWProxyImpl(this._value);

  final GroupedHit _value;

  @override
  GroupedHit hits(List<Hit> hits) => call(hits: hits);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GroupedHit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GroupedHit(...).copyWith(id: 12, name: "My name")
  /// ```
  GroupedHit call({Object? hits = const $CopyWithPlaceholder()}) {
    return GroupedHit(
      hits: hits == const $CopyWithPlaceholder() || hits == null
          ? _value.hits
          // ignore: cast_nullable_to_non_nullable
          : hits as List<Hit>,
    );
  }
}

extension $GroupedHitCopyWith on GroupedHit {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfGroupedHit.copyWith(...)` or `instanceOfGroupedHit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GroupedHitCWProxy get copyWith => _$GroupedHitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupedHit _$GroupedHitFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GroupedHit', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['hits']);
      final val = GroupedHit(
        hits: $checkedConvert(
          'hits',
          (v) => (v as List<dynamic>)
              .map((e) => Hit.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GroupedHitToJson(GroupedHit instance) =>
    <String, dynamic>{'hits': instance.hits.map((e) => e.toJson()).toList()};
