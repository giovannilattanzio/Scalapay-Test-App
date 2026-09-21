# catalog_api.model.ProductSearchResponse

## Load the model package
```dart
import 'package:catalog_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**page** | **int** | Echoes the requested page number. | 
**found** | **int** | **Not a total.** It always equals the number of items actually returned: `per_page=5` gives `found: 5`, `per_page=100` gives `found: 100`. There is no way to learn how many products match overall, so no \"x of y\" progress can be shown and the end of the results cannot be computed from it.  | 
**groupedHits** | [**List&lt;GroupedHit&gt;**](GroupedHit.md) | One entry per result. Each holds a list of hits, and in every response observed that list has exactly one hit, so a product is reached as `grouped_hits[i].hits[0].document`.  | 
**facetCounts** | [**List&lt;FacetCount&gt;**](FacetCount.md) | Facet breakdown by category, merchant, brand and price. | [optional] 
**merchantDetectedFromQuery** | [**DetectedMerchant**](DetectedMerchant.md) | Present only when the whole query is a known brand or merchant (`nike` yes, `nike air force` no). It feeds a merchant banner and has no effect on the ordering of the results.  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


