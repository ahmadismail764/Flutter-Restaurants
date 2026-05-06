import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/restaurant.dart';
import '../services/location_service.dart';
import '../utils/service_locator.dart';
import '../screens/product_list_screen.dart';

class RestaurantDetailsModal extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsModal({super.key, required this.restaurant});

  @override
  State<RestaurantDetailsModal> createState() => _RestaurantDetailsModalState();
}

class _RestaurantDetailsModalState extends State<RestaurantDetailsModal> {
  final LocationService _locationService = getIt<LocationService>();
  
  bool _isLoadingLocation = true;
  double? _distanceKm;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fetchDistance();
  }

  Future<void> _fetchDistance() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final distance = _locationService.calculateDistance(
          position.latitude,
          position.longitude,
          widget.restaurant.latitude,
          widget.restaurant.longitude,
        );
        setState(() {
          _distanceKm = distance;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
      });
    }
  }

  void _getDirections() async {
    try {
      await _locationService.launchMapsDirections(
        widget.restaurant.latitude,
        widget.restaurant.longitude,
        widget.restaurant.name,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.restaurant.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.restaurant.address, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          
          // Distance Info
          if (_isLoadingLocation)
            const Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Calculating distance...', style: TextStyle(color: Colors.grey)),
              ],
            )
          else if (_locationError != null)
            Text('Distance: Unavailable ($_locationError)', style: const TextStyle(color: Colors.red, fontSize: 12))
          else if (_distanceKm != null)
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_distanceKm!.toStringAsFixed(1)} km away', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _getDirections,
                  icon: const Icon(Icons.map),
                  label: const Text('Get Directions'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close modal
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductListScreen(
                          restaurantId: widget.restaurant.id,
                          restaurantName: widget.restaurant.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('View Menu'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
