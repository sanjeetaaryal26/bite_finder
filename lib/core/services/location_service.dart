import 'package:geolocator/geolocator.dart';

class UserLocation {
  final double latitude;
  final double longitude;

  const UserLocation({
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  Future<UserLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException('Location service is disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw const LocationServiceException('Location permission denied.');
    }

    final position = await Geolocator.getCurrentPosition();
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);

  @override
  String toString() => message;
}
