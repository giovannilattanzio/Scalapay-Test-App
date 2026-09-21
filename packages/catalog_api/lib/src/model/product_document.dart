//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_document.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProductDocument {
  /// Returns a new [ProductDocument] instance.
  ProductDocument({

    required  this.id,

    required  this.title,

     this.description,

    required  this.brand,

     this.brandId,

    required  this.merchant,

     this.merchantId,

    required  this.sellingPrice,

    required  this.listPrice,

     this.discountPercentage,

    required  this.image,

     this.imageMerchant,

     this.category,

     this.category1,

     this.category2,

     this.url,

     this.affiliateUrl,

     this.tags,

     this.newOffer,

     this.hasImage,

     this.isMerchantCard,

     this.merchantToken,
  });

      /// Catalog identifier of the offer. Unique within a result set.
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



      /// Product name, as shown on the card.
  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'brand',
    required: true,
    includeIfNull: false,
  )


  final String brand;



  @JsonKey(
    
    name: r'brandId',
    required: false,
    includeIfNull: false,
  )


  final String? brandId;



      /// Store name, as shown on the card.
  @JsonKey(
    
    name: r'merchant',
    required: true,
    includeIfNull: false,
  )


  final String merchant;



  @JsonKey(
    
    name: r'merchantId',
    required: false,
    includeIfNull: false,
  )


  final String? merchantId;



      /// Current price. Typed as a number because the service sends whole amounts as integers (`13`) and others as decimals (`13.38`) in the same response. 
  @JsonKey(
    
    name: r'selling_price',
    required: true,
    includeIfNull: false,
  )


  final double sellingPrice;



      /// Reference price before any discount. Same integer/decimal mix.
  @JsonKey(
    
    name: r'list_price',
    required: true,
    includeIfNull: false,
  )


  final double listPrice;



      /// Observed as an integer, typed as a number for safety.
  @JsonKey(
    
    name: r'discount_percentage',
    required: false,
    includeIfNull: false,
  )


  final double? discountPercentage;



      /// Product image, 300x300.
  @JsonKey(
    
    name: r'image',
    required: true,
    includeIfNull: false,
  )


  final String image;



      /// Merchant logo.
  @JsonKey(
    
    name: r'image_merchant',
    required: false,
    includeIfNull: false,
  )


  final String? imageMerchant;



      /// Full category path, levels separated by \" > \".
  @JsonKey(
    
    name: r'category',
    required: false,
    includeIfNull: false,
  )


  final String? category;



  @JsonKey(
    
    name: r'category_1',
    required: false,
    includeIfNull: false,
  )


  final String? category1;



  @JsonKey(
    
    name: r'category_2',
    required: false,
    includeIfNull: false,
  )


  final String? category2;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(
    
    name: r'affiliate_url',
    required: false,
    includeIfNull: false,
  )


  final String? affiliateUrl;



  @JsonKey(
    
    name: r'tags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? tags;



  @JsonKey(
    
    name: r'new_offer',
    required: false,
    includeIfNull: false,
  )


  final bool? newOffer;



      /// 0 or 1, sent as an integer rather than a boolean, unlike `new_offer`. 
  @JsonKey(
    
    name: r'has_image',
    required: false,
    includeIfNull: false,
  )


  final int? hasImage;



      /// Marks an offer from a Scalapay partner merchant. Present on a minority of documents (8 of 120 sampled across four queries) and absent otherwise. Such a document is a **complete product** — title, brand, merchant, prices and image are all present — so it needs no special handling and can be rendered as any other result. 
  @JsonKey(
    
    name: r'isMerchantCard',
    required: false,
    includeIfNull: false,
  )


  final bool? isMerchantCard;



      /// Scalapay merchant token. Accompanies `isMerchantCard`.
  @JsonKey(
    
    name: r'merchantToken',
    required: false,
    includeIfNull: false,
  )


  final String? merchantToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProductDocument &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.brand == brand &&
      other.brandId == brandId &&
      other.merchant == merchant &&
      other.merchantId == merchantId &&
      other.sellingPrice == sellingPrice &&
      other.listPrice == listPrice &&
      other.discountPercentage == discountPercentage &&
      other.image == image &&
      other.imageMerchant == imageMerchant &&
      other.category == category &&
      other.category1 == category1 &&
      other.category2 == category2 &&
      other.url == url &&
      other.affiliateUrl == affiliateUrl &&
      other.tags == tags &&
      other.newOffer == newOffer &&
      other.hasImage == hasImage &&
      other.isMerchantCard == isMerchantCard &&
      other.merchantToken == merchantToken;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        description.hashCode +
        brand.hashCode +
        brandId.hashCode +
        merchant.hashCode +
        merchantId.hashCode +
        sellingPrice.hashCode +
        listPrice.hashCode +
        discountPercentage.hashCode +
        image.hashCode +
        imageMerchant.hashCode +
        category.hashCode +
        category1.hashCode +
        category2.hashCode +
        url.hashCode +
        affiliateUrl.hashCode +
        tags.hashCode +
        newOffer.hashCode +
        hasImage.hashCode +
        isMerchantCard.hashCode +
        merchantToken.hashCode;

  factory ProductDocument.fromJson(Map<String, dynamic> json) => _$ProductDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDocumentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

