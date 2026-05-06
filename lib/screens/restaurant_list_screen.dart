import 'package:flutter/material.dart';
import '../blocs/restaurant_bloc.dart';
import '../models/restaurant.dart';
import 'product_list_screen.dart';
import 'search_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  late RestaurantBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RestaurantBloc();
    _bloc.fetchRestaurants();
    
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
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<bool>(
        stream: _bloc.isLoading,
        builder: (context, loadingSnapshot) {
          if (loadingSnapshot.data == true) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return StreamBuilder<List<Restaurant>>(
            stream: _bloc.restaurants,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No restaurants found.'));
              }
              
              final restaurants = snapshot.data!;
              return ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
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
                      title: Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text(restaurant.address, maxLines: 2, overflow: TextOverflow.ellipsis),
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
            },
          );
        },
      ),
    );
  }
}
