// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detected_merchant.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DetectedMerchantCWProxy {
  DetectedMerchant id(String? id);

  DetectedMerchant name(String? name);

  DetectedMerchant logo(String? logo);

  DetectedMerchant merchantToken(String? merchantToken);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `DetectedMerchant(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DetectedMerchant(...).copyWith(id: 12, name: "My name")
  /// ```
  DetectedMerchant call({
    String? id,
    String? name,
    String? logo,
    String? merchantToken,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDetectedMerchant.copyWith(...)` or call `instanceOfDetectedMerchant.copyWith.fieldName(value)` for a single field.
class _$DetectedMerchantCWProxyImpl implements _$DetectedMerchantCWProxy {
  const _$DetectedMerchantCWProxyImpl(this._value);

  final DetectedMerchant _value;

  @override
  DetectedMerchant id(String? id) => call(id: id);

  @override
  DetectedMerchant name(String? name) => call(name: name);

  @override
  DetectedMerchant logo(String? logo) => call(logo: logo);

  @override
  DetectedMerchant merchantToken(String? merchantToken) =>
      call(merchantToken: merchantToken);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `DetectedMerchant(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DetectedMerchant(...).copyWith(id: 12, name: "My name")
  /// ```
  DetectedMerchant call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? logo = const $CopyWithPlaceholder(),
    Object? merchantToken = const $CopyWithPlaceholder(),
  }) {
    return DetectedMerchant(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      logo: logo == const $CopyWithPlaceholder()
          ? _value.logo
          // ignore: cast_nullable_to_non_nullable
          : logo as String?,
      merchantToken: merchantToken == const $CopyWithPlaceholder()
          ? _value.merchantToken
          // ignore: cast_nullable_to_non_nullable
          : merchantToken as String?,
    );
  }
}

extension $DetectedMerchantCopyWith on DetectedMerchant {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDetectedMerchant.copyWith(...)` or `instanceOfDetectedMerchant.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DetectedMerchantCWProxy get copyWith => _$DetectedMerchantCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectedMerchant _$DetectedMerchantFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DetectedMerchant', json, ($checkedConvert) {
      final val = DetectedMerchant(
        id: $checkedConvert('id', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        logo: $checkedConvert('logo', (v) => v as String?),
        merchantToken: $checkedConvert('merchantToken', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DetectedMerchantToJson(DetectedMerchant instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': ?instance.name,
      'logo': ?instance.logo,
      'merchantToken': ?instance.merchantToken,
    };
