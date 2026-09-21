//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:catalog_api/src/model/hit.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grouped_hit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GroupedHit {
  /// Returns a new [GroupedHit] instance.
  GroupedHit({

    required  this.hits,
  });

  @JsonKey(
    
    name: r'hits',
    required: true,
    includeIfNull: false,
  )


  final List<Hit> hits;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GroupedHit &&
      other.hits == hits;

    @override
    int get hashCode =>
        hits.hashCode;

  factory GroupedHit.fromJson(Map<String, dynamic> json) => _$GroupedHitFromJson(json);

  Map<String, dynamic> toJson() => _$GroupedHitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

