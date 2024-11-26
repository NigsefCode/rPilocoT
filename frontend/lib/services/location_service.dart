import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/coordinate.dart';

class LocationService {
  // Constantes para ubicaciones en Chile
  static const LatLng TALCA_CENTER = LatLng(-35.4250, -71.6539);

  // Límites aproximados de la región del Maule
  static const double MIN_LAT = -36.5000; // Límite sur
  static const double MAX_LAT = -34.5000; // Límite norte
  static const double MIN_LNG = -72.5000; // Límite oeste
  static const double MAX_LNG = -70.5000; // Límite este

  Future<Coordinate> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Los permisos de ubicación están permanentemente denegados');
      }

      Position position = await Geolocator.getCurrentPosition();

      // Verificar si la ubicación está dentro de los límites de la región
      if (_isLocationInRegion(position.latitude, position.longitude)) {
        return Coordinate(
          lat: position.latitude,
          lng: position.longitude,
          name: 'Mi ubicación',
        );
      } else {
        // Si está fuera de la región, usar Talca como ubicación por defecto
        print(
            'Ubicación fuera de la región permitida. Usando ubicación por defecto.');
        return Coordinate(
          lat: TALCA_CENTER.latitude,
          lng: TALCA_CENTER.longitude,
          name: 'Talca Centro',
        );
      }
    } catch (e) {
      print('Error al obtener ubicación: $e. Usando ubicación por defecto.');
      return Coordinate(
        lat: TALCA_CENTER.latitude,
        lng: TALCA_CENTER.longitude,
        name: 'Talca Centro',
      );
    }
  }

  double calculateDistance(Coordinate start, Coordinate end) {
    return Geolocator.distanceBetween(
      start.lat,
      start.lng,
      end.lat,
      end.lng,
    );
  }

  bool _isLocationInRegion(double lat, double lng) {
    return lat >= MIN_LAT && lat <= MAX_LAT && lng >= MIN_LNG && lng <= MAX_LNG;
  }

  // Puntos de origen predefinidos en Talca
  List<Map<String, dynamic>> getDefaultOrigins() {
    return [
      {
        'name': 'Plaza de Armas de Talca',
        'coordinate': Coordinate(
            lat: -35.4250, lng: -71.6539, name: 'Plaza de Armas de Talca'),
        'description': 'Centro histórico de la ciudad'
      },
      {
        'name': 'Mall Plaza Maule',
        'coordinate':
            Coordinate(lat: -35.4276, lng: -71.6555, name: 'Mall Plaza Maule'),
        'description': 'Centro comercial principal'
      },
      {
        'name': 'Terminal de Buses',
        'coordinate':
            Coordinate(lat: -35.4303, lng: -71.6672, name: 'Terminal de Buses'),
        'description': 'Terminal de buses de Talca'
      },
      {
        'name': 'Universidad de Talca',
        'coordinate': Coordinate(
            lat: -35.4022, lng: -71.6193, name: 'Universidad de Talca'),
        'description': 'Campus principal UTAL'
      }
    ];
  }

  // Destinos disponibles (playas)
  List<Map<String, dynamic>> getAvailableDestinations() {
    return [
      {
        'id': 'pichilemu',
        'name': 'Pichilemu',
        'coordinate':
            Coordinate(lat: -34.3873, lng: -72.0034, name: 'Pichilemu'),
        'description': 'Conocida por sus playas para el surf',
        'distanceFromTalca': 238
      },
      {
        'id': 'iloca',
        'name': 'Iloca',
        'coordinate': Coordinate(lat: -34.9307, lng: -72.1791, name: 'Iloca'),
        'description': 'Playa familiar con aguas tranquilas',
        'distanceFromTalca': 147
      },
      {
        'id': 'constitucion',
        'name': 'Constitución',
        'coordinate':
            Coordinate(lat: -35.3330, lng: -72.4167, name: 'Constitución'),
        'description': 'Ciudad costera con hermosas vistas',
        'distanceFromTalca': 111
      }
    ];
  }
}
