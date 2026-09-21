//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'facet_stats.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FacetStats {
  /// Returns a new [FacetStats] instance.
  FacetStats({

     this.min,

     this.max,
  });

  @JsonKey(
    
    name: r'min',
    required: false,
    includeIfNull: false,
  )


  final double? min;



  @JsonKey(
    
    name: r'max',
    required: false,
    includeIfNull: false,
  )


  final double? max;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FacetStats &&
      other.min == min &&
      other.max == max;

    @override
    int get hashCode =>
        min.hashCode +
        max.hashCode;

  factory FacetStats.fromJson(Map<String, dynamic> json) => _$FacetStatsFromJson(json);

  Map<String, dynamic> toJson() => _$FacetStatsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

