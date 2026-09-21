import 'package:equatable/equatable.dart';

/// A single product returned by a catalog search.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.store,
    required this.brand,
    required this.imageUrl,
    required this.sellingPrice,
    required this.listPrice,
  });

  final String id;
  final String name;
  final String store;
  final String brand;
  final String imageUrl;
  final double sellingPrice;
  final double listPrice;

  /// Every product is payable in 3 instalments; Figma's own placeholder is
  /// inconsistent (85,00 € shown as 3 x 23,33), so the amount is derived
  /// here rather than hardcoded in a widget.
  static const installmentCount = 3;

  double get installmentAmount => sellingPrice / installmentCount;

  @override
  List<Object?> get props => [
    id,
    name,
    store,
    brand,
    imageUrl,
    sellingPrice,
    listPrice,
  ];
}
