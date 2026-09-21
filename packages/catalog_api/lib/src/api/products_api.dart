//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:catalog_api/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:catalog_api/src/model/error_response.dart';
import 'package:catalog_api/src/model/product_search_response.dart';

class ProductsApi {

  final Dio _dio;

  const ProductsApi(this._dio);

  /// Search products in the catalog.
  /// Returns products matching &#x60;q&#x60;, wrapped in a grouping envelope.  Two behaviours matter to any client and are documented on the parameters below: the response carries no total, and paging clamps to the first page once the pages are exhausted instead of ending. 
  ///
  /// Parameters:
  /// * [q] - Free-text search. Matched across several fields, not only the title: `q=scarpe running` returns running shoes whose titles contain neither word, so category and description participate. An empty value returns zero results. 
  /// * [partnerId] - Identifies the calling application. Constant per app.
  /// * [source_] - Identifies the catalog feed. Constant per app.
  /// * [language] - Language of the returned content, as an ISO 639-1 code.
  /// * [country] - Market, as an ISO 3166-1 alpha-2 code.
  /// * [page] - 1-based page number.  **The service does not signal the end of the results.** Past the last page it returns page 1 again, byte-identical, rather than an empty page or an error. Measured on `nike`, `adidas`, `borraccia` and `profumo`: each has exactly 10 pages at `per_page=30`, and page 11 repeats page 1. Pages 12, 13, 40, 100 and 500 also return page 1, so it clamps rather than wrapping modulo. A client must therefore detect the end itself, by recognising a page whose items it has already received. 
  /// * [perPage] - Items per page. A page is never short: every page of every query observed returns exactly this many items, including the last real one.  The reachable window moves with this value — 10 pages at 30, 7 at 50, 4 at 100 — so the number of pages must not be hardcoded by a client. 
  /// * [sortBy] - Ordering, as `<field>:<direction>` with direction `asc` or `desc`.  **Only `selling_price` is honoured.** `_text_match` selects the default relevance order. Every other field — `title`, `brand`, `merchant`, `list_price`, `discount_percentage`, `id`, `category`, `new_offer`, `has_image` — is **accepted and silently ignored**, returning relevance order with no error, as is a nonsense value such as `garbage:asc`. In a comma-separated list the unknown field is dropped and the known one applied. A client must therefore never send a field outside this set: a typo would misreport the ordering instead of failing.  Two further quirks: the leading underscore is not significant (`text_match` is just another ignored field), and the direction is inert on relevance (`_text_match:asc` equals `_text_match:desc`). Omitting the parameter entirely is equivalent to `_text_match:desc`. 
  /// * [filterBy] - Faceted filter expression. The app sends it empty; no non-empty value has been exercised, so its grammar is undocumented here. 
  /// * [minPrice] - Lower bound on `selling_price`, inclusive. Works on its own, and with any `sort_by`. Omit the parameter to leave the lower end unconstrained; do not send an empty value or a zero to mean \"no bound\". 
  /// * [maxPrice] - Upper bound on `selling_price`, inclusive. Works on its own, and with any `sort_by`. Omit the parameter to leave the upper end unconstrained. 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ProductSearchResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ProductSearchResponse>> searchProducts({ 
    required String q,
    required String partnerId,
    required String source_,
    required String language,
    required String country,
    int? page = 1,
    int? perPage = 30,
    String? sortBy = '_text_match:desc',
    String? filterBy = '',
    double? minPrice,
    double? maxPrice,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/products/search';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'q': q,
      if (page != null) r'page': page,
      if (perPage != null) r'per_page': perPage,
      if (sortBy != null) r'sort_by': sortBy,
      if (filterBy != null) r'filter_by': filterBy,
      if (minPrice != null) r'minPrice': minPrice,
      if (maxPrice != null) r'maxPrice': maxPrice,
      r'partnerId': partnerId,
      r'source': source_,
      r'language': language,
      r'country': country,
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    ProductSearchResponse? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<ProductSearchResponse, ProductSearchResponse>(rawData, 'ProductSearchResponse', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ProductSearchResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
