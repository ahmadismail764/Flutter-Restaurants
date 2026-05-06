import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled. Please enable them in your device settings.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied. We cannot calculate distance.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    const Distance distance = Distance();
    // returns distance in meters
    final meter = distance(LatLng(startLat, startLng), LatLng(endLat, endLng));
    return meter / 1000.0; // Returns distance in kilometers
  }

  Future<void> launchMapsDirections(double lat, double lng, String label) async {
    final String url;
    if (Platform.isIOS) {
      url = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';
    } else {
      url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch native maps application.';
    }
  }
}
