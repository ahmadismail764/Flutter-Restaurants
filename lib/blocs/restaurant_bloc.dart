import 'package:rxdart/rxdart.dart';
import '../services/api_service.dart';
import '../utils/service_locator.dart';
import '../models/restaurant.dart';
import '../models/product.dart';

class RestaurantBloc {
  final ApiService _apiService = getIt<ApiService>();

  final _restaurants = BehaviorSubject<List<Restaurant>>();
  final _products = BehaviorSubject<List<Product>>();
  final _isLoading = BehaviorSubject<bool>.seeded(false);
  final _error = PublishSubject<String>();

  Stream<List<Restaurant>> get restaurants => _restaurants.stream;
  Stream<List<Product>> get products => _products.stream;
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String> get error => _error.stream;

  void fetchRestaurants() async {
    _isLoading.sink.add(true);
    try {
      final list = await _apiService.fetchRestaurants();
      _restaurants.sink.add(list);
    } catch (e) {
      _error.sink.add(e.toString());
    } finally {
      _isLoading.sink.add(false);
    }
  }

  void fetchProducts(String restaurantId) async {
    _isLoading.sink.add(true);
    try {
      final list = await _apiService.fetchProducts(restaurantId);
      _products.sink.add(list);
    } catch (e) {
      _error.sink.add(e.toString());
    } finally {
      _isLoading.sink.add(false);
    }
  }

  void dispose() {
    _restaurants.close();
    _products.close();
    _isLoading.close();
    _error.close();
  }
}
