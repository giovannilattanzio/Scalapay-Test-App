//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:catalog_api/src/model/error_detail.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ErrorResponse {
  /// Returns a new [ErrorResponse] instance.
  ErrorResponse({

     this.httpStatusCode,

     this.traceId,

     this.path,

     this.errors,
  });

  @JsonKey(
    
    name: r'httpStatusCode',
    required: false,
    includeIfNull: false,
  )


  final int? httpStatusCode;



  @JsonKey(
    
    name: r'traceId',
    required: false,
    includeIfNull: false,
  )


  final String? traceId;



  @JsonKey(
    
    name: r'path',
    required: false,
    includeIfNull: false,
  )


  final String? path;



  @JsonKey(
    
    name: r'errors',
    required: false,
    includeIfNull: false,
  )


  final List<ErrorDetail>? errors;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ErrorResponse &&
      other.httpStatusCode == httpStatusCode &&
      other.traceId == traceId &&
      other.path == path &&
      other.errors == errors;

    @override
    int get hashCode =>
        httpStatusCode.hashCode +
        traceId.hashCode +
        path.hashCode +
        errors.hashCode;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

