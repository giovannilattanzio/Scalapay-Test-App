// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ErrorDetailCWProxy {
  ErrorDetail message(String? message);

  ErrorDetail code(String? code);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ErrorDetail(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ErrorDetail(...).copyWith(id: 12, name: "My name")
  /// ```
  ErrorDetail call({String? message, String? code});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfErrorDetail.copyWith(...)` or call `instanceOfErrorDetail.copyWith.fieldName(value)` for a single field.
class _$ErrorDetailCWProxyImpl implements _$ErrorDetailCWProxy {
  const _$ErrorDetailCWProxyImpl(this._value);

  final ErrorDetail _value;

  @override
  ErrorDetail message(String? message) => call(message: message);

  @override
  ErrorDetail code(String? code) => call(code: code);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ErrorDetail(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ErrorDetail(...).copyWith(id: 12, name: "My name")
  /// ```
  ErrorDetail call({
    Object? message = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
  }) {
    return ErrorDetail(
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
    );
  }
}

extension $ErrorDetailCopyWith on ErrorDetail {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfErrorDetail.copyWith(...)` or `instanceOfErrorDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ErrorDetailCWProxy get copyWith => _$ErrorDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDetail _$ErrorDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ErrorDetail', json, ($checkedConvert) {
      final val = ErrorDetail(
        message: $checkedConvert('message', (v) => v as String?),
        code: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ErrorDetailToJson(ErrorDetail instance) =>
    <String, dynamic>{'message': ?instance.message, 'code': ?instance.code};
