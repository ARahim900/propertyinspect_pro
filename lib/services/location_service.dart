import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling location-based features
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  
  LocationService._();
  
  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check location permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        throw Exception('Location permission denied');
      }
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }
  
  /// Get address from coordinates (reverse geocoding)
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // This would typically use a geocoding service
      // For now, return formatted coordinates
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }
  
  /// Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
  
  /// Check if location is within inspection area
  bool isWithinInspectionArea(
    Position currentLocation,
    double targetLatitude,
    double targetLongitude, {
    double radiusInMeters = 100.0,
  }) {
    final distance = calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      targetLatitude,
      targetLongitude,
    );
    
    return distance <= radiusInMeters;
  }
  
  /// Get location metadata for inspection
  Future<Map<String, dynamic>> getLocationMetadata() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return {};
      
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'timestamp': position.timestamp?.toIso8601String(),
        'address': address,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}