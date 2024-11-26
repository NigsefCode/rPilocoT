// lib/services/google_maps_service.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/coordinate.dart';
import '../models/destination.dart';

class GoogleMapsService {
  // Obtener ubicación actual
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servicios de ubicación desactivados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  // Convertir polyline a lista de coordenadas
  List<LatLng> decodePolyline(String encodedPolyline) {
    List<LatLng> poly = [];
    int index = 0, len = encodedPolyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;

      do {
        result |= (encodedPolyline.codeUnitAt(index) - 63) << shift;
        shift += 5;
        index++;
      } while (index < len && encodedPolyline.codeUnitAt(index - 1) >= 32);

      if (index >= len) break;

      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;

      do {
        result |= (encodedPolyline.codeUnitAt(index) - 63) << shift;
        shift += 5;
        index++;
      } while (index < len && encodedPolyline.codeUnitAt(index - 1) >= 32);

      if (index >= len) break;

      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return poly;
  }

  // Crear marcadores para el mapa
  Set<Marker> createMarkers({
    required Coordinate origin,
    required Destination destination,
  }) {
    return {
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(origin.lat, origin.lng),
        infoWindow: InfoWindow(title: origin.name),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          destination.coordinates.lat,
          destination.coordinates.lng,
        ),
        infoWindow: InfoWindow(title: destination.name),
      ),
    };
  }
}
