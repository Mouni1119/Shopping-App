import 'package:hive/hive.dart';
import '../models/product_model.dart';

part 'product_hive_adapter.g.dart'; // This will be generated

@HiveType(typeId: 0)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String image;

  @HiveField(6)
  final double ratingRate;

  @HiveField(7)
  final int ratingCount;

  ProductHiveModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.ratingRate,
    required this.ratingCount,
  });

  // Convert from ProductModel to ProductHiveModel
  factory ProductHiveModel.fromProductModel(ProductModel product) {
    return ProductHiveModel(
      id: product.id,
      title: product.title,
      price: product.price,
      description: product.description,
      category: product.category,
      image: product.image,
      ratingRate: product.rating.rate,
      ratingCount: product.rating.count,
    );
  }

  // Convert back to ProductModel
  ProductModel toProductModel() {
    return ProductModel(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      rating: RatingModel(rate: ratingRate, count: ratingCount),
    );
  }
}

// Register the adapter in main.dart