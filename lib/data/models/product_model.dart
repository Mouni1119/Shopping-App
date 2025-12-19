import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'product_model.g.dart'; // For Hive generation

@HiveType(typeId: 1) // Different typeId than ProductHiveModel
class ProductModel extends Equatable {
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
  final RatingModel rating;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        title: json['title']?.toString() ?? '',
        price: json['price'] is num
            ? (json['price'] as num).toDouble()
            : double.parse(json['price'].toString()),
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        rating: json['rating'] != null
            ? RatingModel.fromJson(json['rating'] as Map<String, dynamic>)
            : const RatingModel(rate: 0.0, count: 0),
      );
    } catch (e) {
      throw Exception('Error parsing ProductModel: $e. JSON: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, title, price, description, category, image, rating];
}

@HiveType(typeId: 2)
class RatingModel extends Equatable {
  @HiveField(0)
  final double rate;

  @HiveField(1)
  final int count;

  const RatingModel({
    required this.rate,
    required this.count,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    try {
      return RatingModel(
        rate: json['rate'] is num
            ? (json['rate'] as num).toDouble()
            : double.parse(json['rate'].toString()),
        count: json['count'] is int
            ? json['count']
            : int.parse(json['count'].toString()),
      );
    } catch (e) {
      throw Exception('Error parsing RatingModel: $e. JSON: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'count': count,
    };
  }

  @override
  List<Object?> get props => [rate, count];
}