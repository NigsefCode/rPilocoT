// lib/services/route_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteService {
  static const String baseUrl = 'http://localhost:5000/api/routes';
  final String? token;

  RouteService({required this.token}) {
    if (token == null) {
      throw Exception('Se requiere token para inicializar RouteService');
    }
  }

  static const Map<String, Map<String, dynamic>> DESTINATIONS = {
    'PICHILEMU': {
      'name': 'Pichilemu',
      'coordinates': {'lat': -34.3867, 'lng': -72.0033},
      'stops': ['Santa Cruz', 'Lolol'],
    },
    'CONSTITUCION': {
      'name': 'Constitución',
      'coordinates': {'lat': -35.3332, 'lng': -72.4167},
      'stops': ['Maule'],
    },
    'ILOCA': {
      'name': 'Iloca',
      'coordinates': {'lat': -34.9307, 'lng': -72.1791},
      'stops': ['Duao'],
    },
  };

  static const Map<String, dynamic> TALCA_ORIGIN = {
    'name': 'Talca',
    'coordinates': {
      'lat': -35.4272,
      'lng': -71.6554,
    },
  };

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> calculateRoute({
    required String destination,
    required String vehicleId,
    bool isOptimalRoute = true,
  }) async {
    try {
      final destinationInfo = DESTINATIONS[destination];
      if (destinationInfo == null) {
        throw Exception('Destino no válido');
      }

      // Simplificar el body de la petición
      final requestBody = {
        'destination':
            destination, // Solo el nombre: "PICHILEMU", "ILOCA", etc.
        'vehicleId': vehicleId,
        'routeType': isOptimalRoute ? 'optimal' : 'fastest'
      };

      print('Enviando petición con datos: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/calculate'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          ...responseData,
          'stops': destinationInfo['stops'],
          'tips': responseData['tips'] ?? [],
        };
      } else {
        throw Exception('Error: ${_parseError(response.body)}');
      }
    } catch (e) {
      print('Error en calculateRoute: $e');
      rethrow;
    }
  }

  List<Map<String, double>> _generateWaypoints(List<String> stops) {
    // Aquí podrías tener un mapa de coordenadas para las paradas
    // Por ahora retornamos una lista vacía
    return [];
  }

  List<String> _generateTips(String destination, String trafficLevel) {
    List<String> tips = [];

    // Tips básicos según el destino
    switch (destination) {
      case 'PICHILEMU':
        tips.add('Ruta con curvas pronunciadas. Conducir con precaución');
        tips.add('Paradas recomendadas en Santa Cruz y Lolol');
        break;
      case 'ILOCA':
        tips.add('Ruta costera. Atención a la neblina en temporada');
        tips.add('Parada recomendada en Duao');
        break;
      case 'CONSTITUCION':
        tips.add('Ruta directa con buen estado de camino');
        tips.add('Parada recomendada en Maule');
        break;
    }

    // Tips según nivel de tráfico
    switch (trafficLevel.toLowerCase()) {
      case 'high':
        tips.add('Alto nivel de tráfico. Considere salir más temprano');
        break;
      case 'medium':
        tips.add('Tráfico moderado. Tiempo de viaje normal');
        break;
      case 'low':
        tips.add('Tráfico bajo. Condiciones favorables para viajar');
        break;
    }

    return tips;
  }

  Map<String, dynamic> _processMapData(Map<String, dynamic> mapData) {
    return {
      'polyline': mapData['polyline'],
      'bounds': LatLngBounds(
        southwest: LatLng(
          mapData['bounds']['southwest']['lat'],
          mapData['bounds']['southwest']['lng'],
        ),
        northeast: LatLng(
          mapData['bounds']['northeast']['lat'],
          mapData['bounds']['northeast']['lng'],
        ),
      ),
      'waypoints': List<LatLng>.from(
        (mapData['waypoints'] as List).map(
          (point) => LatLng(point['lat'], point['lng']),
        ),
      ),
    };
  }

  Future<List<Route>> getRouteHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Route.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${_parseError(response.body)}');
      }
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }

  Future<Route> getRouteById(String routeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$routeId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Route.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error: ${_parseError(response.body)}');
      }
    } catch (e) {
      throw Exception('Error al obtener la ruta: $e');
    }
  }

  Future<Map<String, double>> getFuelPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fuel-prices'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, value.toDouble()));
      } else {
        throw Exception('Error: ${_parseError(response.body)}');
      }
    } catch (e) {
      throw Exception('Error al obtener precios de combustible: $e');
    }
  }

  String _parseError(String body) {
    try {
      Map<String, dynamic> error = json.decode(body);
      return error['message'] ?? 'Error desconocido';
    } catch (e) {
      return body;
    }
  }

  static List<Map<String, dynamic>> getPresetDestinations() {
    return DESTINATIONS.entries
        .map((entry) => {
              'name': entry.value['name'],
              'coordinates': entry.value['coordinates'],
              'stops': entry.value['stops'],
            })
        .toList();
  }

  static LatLng getTalcaLocation() {
    return LatLng(
      TALCA_ORIGIN['coordinates']!['lat'] as double,
      TALCA_ORIGIN['coordinates']!['lng'] as double,
    );
  }
}
