import 'package:rxdart/rxdart.dart';
import '../services/api_service.dart';
import '../utils/service_locator.dart';
import '../models/restaurant.dart';
import '../models/product.dart';

class SearchBloc {
  final ApiService _apiService = getIt<ApiService>();

  // Inputs
  final _searchQuery = BehaviorSubject<String>();
  final _selectedProduct = BehaviorSubject<Product>();
  final _isMapView = BehaviorSubject<bool>.seeded(false);

  // Outputs
  final _isLoading = BehaviorSubject<bool>.seeded(false);
  final _error = PublishSubject<String>();
  final _searchResults = BehaviorSubject<List<Restaurant>>();

  // Available products to populate the search dropdown
  final _allProducts = BehaviorSubject<List<Product>>();

  SearchBloc() {
    _initProducts();

    // Listen to selected product changes and automatically fetch restaurants
    _selectedProduct.listen((product) {
      _searchRestaurantsByProduct(product);
    });
  }

  // Sinks (Inputs)
  Function(String) get changeSearchQuery => _searchQuery.sink.add;
  Function(Product) get changeSelectedProduct => _selectedProduct.sink.add;
  
  void toggleView() {
    _isMapView.sink.add(!_isMapView.value);
  }

  // Streams (Outputs)
  Stream<String> get searchQuery => _searchQuery.stream;
  Stream<Product> get selectedProduct => _selectedProduct.stream;
  Stream<bool> get isMapView => _isMapView.stream;
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String> get error => _error.stream;
  Stream<List<Restaurant>> get searchResults => _searchResults.stream;
  Stream<List<Product>> get allProducts => _allProducts.stream;

  Future<void> _initProducts() async {
    try {
      _isLoading.sink.add(true);
      // Mocking fetching all unique available products globally
      final restaurants = await _apiService.fetchRestaurants();
      final productsSet = <Product>{};
      for (var r in restaurants) {
        productsSet.addAll(r.products);
      }
      _allProducts.sink.add(productsSet.toList());
    } catch (e) {
      _error.sink.add(e.toString());
    } finally {
      _isLoading.sink.add(false);
    }
  }

  Future<void> _searchRestaurantsByProduct(Product product) async {
    try {
      _isLoading.sink.add(true);
      final results = await _apiService.searchRestaurantsByProduct(product);
      _searchResults.sink.add(results);
    } catch (e) {
      _error.sink.add(e.toString());
    } finally {
      _isLoading.sink.add(false);
    }
  }

  void dispose() {
    _searchQuery.close();
    _selectedProduct.close();
    _isMapView.close();
    _isLoading.close();
    _error.close();
    _searchResults.close();
    _allProducts.close();
  }
}
