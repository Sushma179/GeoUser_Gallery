import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Map<String, String>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'location': 'Location services are disabled. Please enable them.',
          'address': ''
        };
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'location': 'Location permissions are denied.',
            'address': ''
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'location': 'Location permissions are permanently denied.',
          'address': ''
        };
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocode to get placemark
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();

      String address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
      String location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      
      return {'location': location, 'address': address};
    } catch (e) {
      return {
        'location': 'Failed to get location: ${e.toString()}',
        'address': ''
      };
    }
  }
}
