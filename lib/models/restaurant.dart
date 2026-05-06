import 'package:equatable/equatable.dart';
import 'product.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final List<Product> products;

  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.products,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var productsList = json['products'] as List? ?? [];
    List<Product> parsedProducts = productsList.map((i) => Product.fromJson(i)).toList();

    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      imageUrl: json['imageUrl'],
      products: parsedProducts,
    );
  }

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, imageUrl, products];
}
