import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/restaurant.dart';
import '../models/product.dart';
import 'api_service.dart';

class HttpApiService implements ApiService {
  final String baseUrl = 'https://restaurantapifci.pythonanywhere.com';

  @override
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to login');
    }
  }

  @override
  Future<User> signup({
    required String name,
    required String email,
    required String password,
    String? gender,
    int? level,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'gender': gender,
        'level': level,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to signup');
    }
  }

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants'));

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Restaurant>.from(l.map((model) => Restaurant.fromJson(model)));
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  @override
  Future<List<Product>> fetchProducts(String restaurantId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$restaurantId'));

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Product>.from(l.map((model) => Product.fromJson(model)));
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<List<Restaurant>> searchRestaurantsByProduct(Product product) async {
    // In lieu of a specific backend search endpoint, we fetch all and filter locally
    final restaurants = await fetchRestaurants();
    return restaurants.where((r) => r.products.any((p) => p.id == product.id)).toList();
  }
}
