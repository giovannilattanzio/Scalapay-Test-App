//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'detected_merchant.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DetectedMerchant {
  /// Returns a new [DetectedMerchant] instance.
  DetectedMerchant({

     this.id,

     this.name,

     this.logo,

     this.merchantToken,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'logo',
    required: false,
    includeIfNull: false,
  )


  final String? logo;



  @JsonKey(
    
    name: r'merchantToken',
    required: false,
    includeIfNull: false,
  )


  final String? merchantToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DetectedMerchant &&
      other.id == id &&
      other.name == name &&
      other.logo == logo &&
      other.merchantToken == merchantToken;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        logo.hashCode +
        merchantToken.hashCode;

  factory DetectedMerchant.fromJson(Map<String, dynamic> json) => _$DetectedMerchantFromJson(json);

  Map<String, dynamic> toJson() => _$DetectedMerchantToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

