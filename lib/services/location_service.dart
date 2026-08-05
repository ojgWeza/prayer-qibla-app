import 'package:geolocator/geolocator.dart';

enum LocationState { granted, denied, deniedForever, serviceDisabled }

class LocationResult {
  final LocationState state;
  final Position? position;
  const LocationResult(this.state, this.position);
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(LocationState.serviceDisabled, null);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationResult(LocationState.denied, null);
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(LocationState.deniedForever, null);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
    return LocationResult(LocationState.granted, position);
  }

  Future<Position?> getLastKnownLocation() => Geolocator.getLastKnownPosition();
}
