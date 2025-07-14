import 'package:flutter_store/models/CartProduct.dart';
import 'package:flutter_store/models/products.dart';

class FavouriteProduct {
  final String favouriteId;
  final String title;
  final String image;
  final double price;
  final String category;
  final double rating;

  FavouriteProduct({
    required this.favouriteId,
    required this.title,
    required this.image,
    required this.price,
    required this.category,
    required this.rating,
  });

  factory FavouriteProduct.fromJson(Map<String, dynamic> json) {
    return FavouriteProduct(
      favouriteId: json['id'],
      title: json['title'],
      image: json['image'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avouriteId': favouriteId,
      'title': title,
      'image': image,
      'price': price,
      'category': category,
      'rating': rating,
    };
  }
}
