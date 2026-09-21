//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:catalog_api/src/model/facet_stats.dart';
import 'package:catalog_api/src/model/facet_value.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'facet_count.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FacetCount {
  /// Returns a new [FacetCount] instance.
  FacetCount({

     this.fieldName,

     this.counts,

     this.stats,
  });

      /// One of `category`, `merchant`, `brand`, `selling_price`.
  @JsonKey(
    
    name: r'field_name',
    required: false,
    includeIfNull: false,
  )


  final String? fieldName;



  @JsonKey(
    
    name: r'counts',
    required: false,
    includeIfNull: false,
  )


  final List<FacetValue>? counts;



  @JsonKey(
    
    name: r'stats',
    required: false,
    includeIfNull: false,
  )


  final FacetStats? stats;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FacetCount &&
      other.fieldName == fieldName &&
      other.counts == counts &&
      other.stats == stats;

    @override
    int get hashCode =>
        fieldName.hashCode +
        counts.hashCode +
        stats.hashCode;

  factory FacetCount.fromJson(Map<String, dynamic> json) => _$FacetCountFromJson(json);

  Map<String, dynamic> toJson() => _$FacetCountToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

