# catalog_api.model.ProductDocument

## Load the model package
```dart
import 'package:catalog_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Catalog identifier of the offer. Unique within a result set. | 
**title** | **String** | Product name, as shown on the card. | 
**description** | **String** |  | [optional] 
**brand** | **String** |  | 
**brandId** | **String** |  | [optional] 
**merchant** | **String** | Store name, as shown on the card. | 
**merchantId** | **String** |  | [optional] 
**sellingPrice** | **double** | Current price. Typed as a number because the service sends whole amounts as integers (`13`) and others as decimals (`13.38`) in the same response.  | 
**listPrice** | **double** | Reference price before any discount. Same integer/decimal mix. | 
**discountPercentage** | **double** | Observed as an integer, typed as a number for safety. | [optional] 
**image** | **String** | Product image, 300x300. | 
**imageMerchant** | **String** | Merchant logo. | [optional] 
**category** | **String** | Full category path, levels separated by \" > \". | [optional] 
**category1** | **String** |  | [optional] 
**category2** | **String** |  | [optional] 
**url** | **String** |  | [optional] 
**affiliateUrl** | **String** |  | [optional] 
**tags** | **List&lt;String&gt;** |  | [optional] 
**newOffer** | **bool** |  | [optional] 
**hasImage** | **int** | 0 or 1, sent as an integer rather than a boolean, unlike `new_offer`.  | [optional] 
**isMerchantCard** | **bool** | Marks an offer from a Scalapay partner merchant. Present on a minority of documents (8 of 120 sampled across four queries) and absent otherwise. Such a document is a **complete product** — title, brand, merchant, prices and image are all present — so it needs no special handling and can be rendered as any other result.  | [optional] 
**merchantToken** | **String** | Scalapay merchant token. Accompanies `isMerchantCard`. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


