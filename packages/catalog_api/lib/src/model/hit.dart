//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:catalog_api/src/model/product_document.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Hit {
  /// Returns a new [Hit] instance.
  Hit({

    required  this.document,
  });

  @JsonKey(
    
    name: r'document',
    required: true,
    includeIfNull: false,
  )


  final ProductDocument document;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Hit &&
      other.document == document;

    @override
    int get hashCode =>
        document.hashCode;

  factory Hit.fromJson(Map<String, dynamic> json) => _$HitFromJson(json);

  Map<String, dynamic> toJson() => _$HitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

