import 'package:flutter/material.dart';
import '../blocs/restaurant_bloc.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const ProductListScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late RestaurantBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RestaurantBloc();
    _bloc.fetchProducts(widget.restaurantId);
    
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
      appBar: AppBar(title: Text('${widget.restaurantName} Menu')),
      body: StreamBuilder<bool>(
        stream: _bloc.isLoading,
        builder: (context, loadingSnapshot) {
          if (loadingSnapshot.data == true) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return StreamBuilder<List<Product>>(
            stream: _bloc.products,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products available.'));
              }
              
              final products = snapshot.data!;
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          product.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 60),
                        ),
                      ),
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
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
