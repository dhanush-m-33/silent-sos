import 'package:geolocator/geolocator.dart';

/// Gets the device's current GPS coordinates.
class LocationService {
  /// Returns coordinates as "lat,lng" string, e.g. "12.9716,77.5946".
  /// Returns "0.0,0.0" if location cannot be determined.
  static Future<String> getCoordinates() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return '0.0,0.0';

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return '0.0,0.0';
      }
      if (permission == LocationPermission.deniedForever) return '0.0,0.0';

      // Get position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return '${position.latitude},${position.longitude}';
    } catch (_) {
      return '0.0,0.0';
    }
  }
}
