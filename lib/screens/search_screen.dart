import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../blocs/search_bloc.dart';
import '../models/product.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_details_modal.dart';
import 'product_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late SearchBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = SearchBloc();
    _bloc.error.listen((errorMsg) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search by Product'),
        actions: [
          StreamBuilder<bool>(
            stream: _bloc.isMapView,
            builder: (context, snapshot) {
              final isMap = snapshot.data ?? false;
              return IconButton(
                icon: Icon(isMap ? Icons.list : Icons.map),
                tooltip: isMap ? 'List View' : 'Map View',
                onPressed: _bloc.toggleView,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Search Input / Dropdown for selecting a product
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<List<Product>>(
              stream: _bloc.allProducts,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                
                final products = snapshot.data!;
                return StreamBuilder<Product>(
                  stream: _bloc.selectedProduct,
                  builder: (context, selectedSnapshot) {
                    return DropdownButtonFormField<Product>(
                      decoration: const InputDecoration(
                        labelText: 'Select a Product to search',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      value: selectedSnapshot.data,
                      items: products.map((product) {
                        return DropdownMenuItem<Product>(
                          value: product,
                          child: Text(product.name),
                        );
                      }).toList(),
                      onChanged: (product) {
                        if (product != null) {
                          _bloc.changeSelectedProduct(product);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Results Section (List View or Map View Toggle)
          Expanded(
            child: StreamBuilder<bool>(
              stream: _bloc.isLoading,
              builder: (context, loadingSnapshot) {
                if (loadingSnapshot.data == true) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return StreamBuilder<List<Restaurant>>(
                  stream: _bloc.searchResults,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('Select a product to find restaurants.'));
                    }
                    if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('No restaurants found for this product.'));
                    }
                    
                    final results = snapshot.data!;
                    
                    return StreamBuilder<bool>(
                      stream: _bloc.isMapView,
                      builder: (context, viewSnapshot) {
                        final isMap = viewSnapshot.data ?? false;
                        
                        if (isMap) {
                          return _buildMapView(results);
                        } else {
                          return _buildListView(results);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Restaurant> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final restaurant = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                restaurant.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.restaurant, size: 60),
              ),
            ),
            title: Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(restaurant.address),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    restaurantId: restaurant.id,
                    restaurantName: restaurant.name,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<Restaurant> results) {
    // Center map around the first result or a default coordinate
    final initialCenter = results.isNotEmpty 
        ? LatLng(results.first.latitude, results.first.longitude)
        : const LatLng(40.7128, -74.0060);
        
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 14.0,
      ),
      children: [
        /* 
         * NOTE ON API KEYS:
         * We are using OpenStreetMap tiles here via flutter_map, which does NOT require an API Key.
         * If you switch to Google Maps (`google_maps_flutter`) or Mapbox, you MUST inject your API key.
         * For Google Maps, add it to your AndroidManifest.xml:
         * <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY_HERE"/>
         * And to iOS AppDelegate.swift: GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
         */
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.restaurant_app',
        ),
        MarkerLayer(
          markers: results.map((r) {
            return Marker(
              point: LatLng(r.latitude, r.longitude),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _buildMarkerModal(r),
                  );
                },
                child: const Icon(Icons.location_on, color: Colors.red, size: 50),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarkerModal(Restaurant restaurant) {
    return RestaurantDetailsModal(restaurant: restaurant);
  }
}
