import '../models/user.dart';
import '../models/restaurant.dart';
import '../models/product.dart';

abstract class ApiService {
  Future<User> login(String email, String password);
  Future<User> signup({
    required String name,
    required String email,
    required String password,
    String? gender,
    int? level,
  });
  Future<List<Restaurant>> fetchRestaurants();
  Future<List<Product>> fetchProducts(String restaurantId);
  Future<List<Restaurant>> searchRestaurantsByProduct(Product product);
}
