// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HitCWProxy {
  Hit document(ProductDocument document);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Hit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Hit(...).copyWith(id: 12, name: "My name")
  /// ```
  Hit call({ProductDocument document});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHit.copyWith(...)` or call `instanceOfHit.copyWith.fieldName(value)` for a single field.
class _$HitCWProxyImpl implements _$HitCWProxy {
  const _$HitCWProxyImpl(this._value);

  final Hit _value;

  @override
  Hit document(ProductDocument document) => call(document: document);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Hit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Hit(...).copyWith(id: 12, name: "My name")
  /// ```
  Hit call({Object? document = const $CopyWithPlaceholder()}) {
    return Hit(
      document: document == const $CopyWithPlaceholder() || document == null
          ? _value.document
          // ignore: cast_nullable_to_non_nullable
          : document as ProductDocument,
    );
  }
}

extension $HitCopyWith on Hit {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHit.copyWith(...)` or `instanceOfHit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HitCWProxy get copyWith => _$HitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hit _$HitFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Hit', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['document']);
      final val = Hit(
        document: $checkedConvert(
          'document',
          (v) => ProductDocument.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HitToJson(Hit instance) => <String, dynamic>{
  'document': instance.document.toJson(),
};
