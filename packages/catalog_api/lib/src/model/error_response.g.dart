// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ErrorResponseCWProxy {
  ErrorResponse httpStatusCode(int? httpStatusCode);

  ErrorResponse traceId(String? traceId);

  ErrorResponse path(String? path);

  ErrorResponse errors(List<ErrorDetail>? errors);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ErrorResponse(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ErrorResponse(...).copyWith(id: 12, name: "My name")
  /// ```
  ErrorResponse call({
    int? httpStatusCode,
    String? traceId,
    String? path,
    List<ErrorDetail>? errors,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfErrorResponse.copyWith(...)` or call `instanceOfErrorResponse.copyWith.fieldName(value)` for a single field.
class _$ErrorResponseCWProxyImpl implements _$ErrorResponseCWProxy {
  const _$ErrorResponseCWProxyImpl(this._value);

  final ErrorResponse _value;

  @override
  ErrorResponse httpStatusCode(int? httpStatusCode) =>
      call(httpStatusCode: httpStatusCode);

  @override
  ErrorResponse traceId(String? traceId) => call(traceId: traceId);

  @override
  ErrorResponse path(String? path) => call(path: path);

  @override
  ErrorResponse errors(List<ErrorDetail>? errors) => call(errors: errors);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ErrorResponse(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ErrorResponse(...).copyWith(id: 12, name: "My name")
  /// ```
  ErrorResponse call({
    Object? httpStatusCode = const $CopyWithPlaceholder(),
    Object? traceId = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
  }) {
    return ErrorResponse(
      httpStatusCode: httpStatusCode == const $CopyWithPlaceholder()
          ? _value.httpStatusCode
          // ignore: cast_nullable_to_non_nullable
          : httpStatusCode as int?,
      traceId: traceId == const $CopyWithPlaceholder()
          ? _value.traceId
          // ignore: cast_nullable_to_non_nullable
          : traceId as String?,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String?,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as List<ErrorDetail>?,
    );
  }
}

extension $ErrorResponseCopyWith on ErrorResponse {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfErrorResponse.copyWith(...)` or `instanceOfErrorResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ErrorResponseCWProxy get copyWith => _$ErrorResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ErrorResponse', json, ($checkedConvert) {
      final val = ErrorResponse(
        httpStatusCode: $checkedConvert(
          'httpStatusCode',
          (v) => (v as num?)?.toInt(),
        ),
        traceId: $checkedConvert('traceId', (v) => v as String?),
        path: $checkedConvert('path', (v) => v as String?),
        errors: $checkedConvert(
          'errors',
          (v) => (v as List<dynamic>?)
              ?.map((e) => ErrorDetail.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'httpStatusCode': ?instance.httpStatusCode,
      'traceId': ?instance.traceId,
      'path': ?instance.path,
      'errors': ?instance.errors?.map((e) => e.toJson()).toList(),
    };
