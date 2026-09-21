# catalog_api.api.ProductsApi

## Load the API package
```dart
import 'package:catalog_api/api.dart';
```

All URIs are relative to *https://catalog-api.dev-cat.scalapay.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**searchProducts**](ProductsApi.md#searchproducts) | **GET** /v1/products/search | Search products in the catalog.


# **searchProducts**
> ProductSearchResponse searchProducts(q, partnerId, source_, language, country, page, perPage, sortBy, filterBy, minPrice, maxPrice)

Search products in the catalog.

Returns products matching `q`, wrapped in a grouping envelope.  Two behaviours matter to any client and are documented on the parameters below: the response carries no total, and paging clamps to the first page once the pages are exhausted instead of ending. 

### Example
```dart
import 'package:catalog_api/api.dart';

final api = CatalogApi().getProductsApi();
final String q = nike; // String | Free-text search. Matched across several fields, not only the title: `q=scarpe running` returns running shoes whose titles contain neither word, so category and description participate. An empty value returns zero results. 
final String partnerId = scalapayappit; // String | Identifies the calling application. Constant per app.
final String source_ = trovaprezzi; // String | Identifies the catalog feed. Constant per app.
final String language = it; // String | Language of the returned content, as an ISO 639-1 code.
final String country = IT; // String | Market, as an ISO 3166-1 alpha-2 code.
final int page = 1; // int | 1-based page number.  **The service does not signal the end of the results.** Past the last page it returns page 1 again, byte-identical, rather than an empty page or an error. Measured on `nike`, `adidas`, `borraccia` and `profumo`: each has exactly 10 pages at `per_page=30`, and page 11 repeats page 1. Pages 12, 13, 40, 100 and 500 also return page 1, so it clamps rather than wrapping modulo. A client must therefore detect the end itself, by recognising a page whose items it has already received. 
final int perPage = 30; // int | Items per page. A page is never short: every page of every query observed returns exactly this many items, including the last real one.  The reachable window moves with this value — 10 pages at 30, 7 at 50, 4 at 100 — so the number of pages must not be hardcoded by a client. 
final String sortBy = _text_match:desc; // String | Ordering, as `<field>:<direction>` with direction `asc` or `desc`.  **Only `selling_price` is honoured.** `_text_match` selects the default relevance order. Every other field — `title`, `brand`, `merchant`, `list_price`, `discount_percentage`, `id`, `category`, `new_offer`, `has_image` — is **accepted and silently ignored**, returning relevance order with no error, as is a nonsense value such as `garbage:asc`. In a comma-separated list the unknown field is dropped and the known one applied. A client must therefore never send a field outside this set: a typo would misreport the ordering instead of failing.  Two further quirks: the leading underscore is not significant (`text_match` is just another ignored field), and the direction is inert on relevance (`_text_match:asc` equals `_text_match:desc`). Omitting the parameter entirely is equivalent to `_text_match:desc`. 
final String filterBy = filterBy_example; // String | Faceted filter expression. The app sends it empty; no non-empty value has been exercised, so its grammar is undocumented here. 
final double minPrice = 100.0; // double | Lower bound on `selling_price`, inclusive. Works on its own, and with any `sort_by`. Omit the parameter to leave the lower end unconstrained; do not send an empty value or a zero to mean \"no bound\". 
final double maxPrice = 200.0; // double | Upper bound on `selling_price`, inclusive. Works on its own, and with any `sort_by`. Omit the parameter to leave the upper end unconstrained. 

try {
    final response = api.searchProducts(q, partnerId, source_, language, country, page, perPage, sortBy, filterBy, minPrice, maxPrice);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ProductsApi->searchProducts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**| Free-text search. Matched across several fields, not only the title: `q=scarpe running` returns running shoes whose titles contain neither word, so category and description participate. An empty value returns zero results.  | 
 **partnerId** | **String**| Identifies the calling application. Constant per app. | 
 **source_** | **String**| Identifies the catalog feed. Constant per app. | 
 **language** | **String**| Language of the returned content, as an ISO 639-1 code. | 
 **country** | **String**| Market, as an ISO 3166-1 alpha-2 code. | 
 **page** | **int**| 1-based page number.  **The service does not signal the end of the results.** Past the last page it returns page 1 again, byte-identical, rather than an empty page or an error. Measured on `nike`, `adidas`, `borraccia` and `profumo`: each has exactly 10 pages at `per_page=30`, and page 11 repeats page 1. Pages 12, 13, 40, 100 and 500 also return page 1, so it clamps rather than wrapping modulo. A client must therefore detect the end itself, by recognising a page whose items it has already received.  | [optional] [default to 1]
 **perPage** | **int**| Items per page. A page is never short: every page of every query observed returns exactly this many items, including the last real one.  The reachable window moves with this value — 10 pages at 30, 7 at 50, 4 at 100 — so the number of pages must not be hardcoded by a client.  | [optional] [default to 30]
 **sortBy** | **String**| Ordering, as `<field>:<direction>` with direction `asc` or `desc`.  **Only `selling_price` is honoured.** `_text_match` selects the default relevance order. Every other field — `title`, `brand`, `merchant`, `list_price`, `discount_percentage`, `id`, `category`, `new_offer`, `has_image` — is **accepted and silently ignored**, returning relevance order with no error, as is a nonsense value such as `garbage:asc`. In a comma-separated list the unknown field is dropped and the known one applied. A client must therefore never send a field outside this set: a typo would misreport the ordering instead of failing.  Two further quirks: the leading underscore is not significant (`text_match` is just another ignored field), and the direction is inert on relevance (`_text_match:asc` equals `_text_match:desc`). Omitting the parameter entirely is equivalent to `_text_match:desc`.  | [optional] [default to '_text_match:desc']
 **filterBy** | **String**| Faceted filter expression. The app sends it empty; no non-empty value has been exercised, so its grammar is undocumented here.  | [optional] [default to '']
 **minPrice** | **double**| Lower bound on `selling_price`, inclusive. Works on its own, and with any `sort_by`. Omit the parameter to leave the lower end unconstrained; do not send an empty value or a zero to mean \"no bound\".  | [optional] 
 **maxPrice** | **double**| Upper bound on `selling_price`, inclusive. Works on its own, and with any `sort_by`. Omit the parameter to leave the upper end unconstrained.  | [optional] 

### Return type

[**ProductSearchResponse**](ProductSearchResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

