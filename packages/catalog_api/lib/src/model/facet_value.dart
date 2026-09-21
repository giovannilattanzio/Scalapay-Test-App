//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'facet_value.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FacetValue {
  /// Returns a new [FacetValue] instance.
  FacetValue({

     this.count,

     this.highlighted,

     this.value,
  });

  @JsonKey(
    
    name: r'count',
    required: false,
    includeIfNull: false,
  )


  final int? count;



  @JsonKey(
    
    name: r'highlighted',
    required: false,
    includeIfNull: false,
  )


  final String? highlighted;



  @JsonKey(
    
    name: r'value',
    required: false,
    includeIfNull: false,
  )


  final String? value;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FacetValue &&
      other.count == count &&
      other.highlighted == highlighted &&
      other.value == value;

    @override
    int get hashCode =>
        count.hashCode +
        highlighted.hashCode +
        value.hashCode;

  factory FacetValue.fromJson(Map<String, dynamic> json) => _$FacetValueFromJson(json);

  Map<String, dynamic> toJson() => _$FacetValueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

