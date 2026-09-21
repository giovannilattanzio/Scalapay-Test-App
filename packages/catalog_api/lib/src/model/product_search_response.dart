//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:catalog_api/src/model/detected_merchant.dart';
import 'package:catalog_api/src/model/grouped_hit.dart';
import 'package:catalog_api/src/model/facet_count.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_search_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProductSearchResponse {
  /// Returns a new [ProductSearchResponse] instance.
  ProductSearchResponse({

    required  this.page,

    required  this.found,

    required  this.groupedHits,

     this.facetCounts,

     this.merchantDetectedFromQuery,
  });

      /// Echoes the requested page number.
  @JsonKey(
    
    name: r'page',
    required: true,
    includeIfNull: false,
  )


  final int page;



      /// **Not a total.** It always equals the number of items actually returned: `per_page=5` gives `found: 5`, `per_page=100` gives `found: 100`. There is no way to learn how many products match overall, so no \"x of y\" progress can be shown and the end of the results cannot be computed from it. 
  @JsonKey(
    
    name: r'found',
    required: true,
    includeIfNull: false,
  )


  final int found;



      /// One entry per result. Each holds a list of hits, and in every response observed that list has exactly one hit, so a product is reached as `grouped_hits[i].hits[0].document`. 
  @JsonKey(
    
    name: r'grouped_hits',
    required: true,
    includeIfNull: false,
  )


  final List<GroupedHit> groupedHits;



      /// Facet breakdown by category, merchant, brand and price.
  @JsonKey(
    
    name: r'facet_counts',
    required: false,
    includeIfNull: false,
  )


  final List<FacetCount>? facetCounts;



      /// Present only when the whole query is a known brand or merchant (`nike` yes, `nike air force` no). It feeds a merchant banner and has no effect on the ordering of the results. 
  @JsonKey(
    
    name: r'merchantDetectedFromQuery',
    required: false,
    includeIfNull: false,
  )


  final DetectedMerchant? merchantDetectedFromQuery;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProductSearchResponse &&
      other.page == page &&
      other.found == found &&
      other.groupedHits == groupedHits &&
      other.facetCounts == facetCounts &&
      other.merchantDetectedFromQuery == merchantDetectedFromQuery;

    @override
    int get hashCode =>
        page.hashCode +
        found.hashCode +
        groupedHits.hashCode +
        facetCounts.hashCode +
        (merchantDetectedFromQuery == null ? 0 : merchantDetectedFromQuery.hashCode);

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) => _$ProductSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSearchResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

