import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final double price;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, price];
}
