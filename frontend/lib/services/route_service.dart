import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Agregar esta importación
import '../models/route_model.dart';
import '../models/coordinate.dart';
import 'config_service.dart';
import 'auth_service.dart';

class RouteService {
  final String baseUrl = ConfigService.baseUrl;
  final AuthService _authService = AuthService();

  // Agregar el método _getAuthHeaders
  // Método auxiliar para obtener headers con autenticación
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación disponible');
      }
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('Error obteniendo headers de autenticación: $e'); // Debug
      rethrow;
    }
  }

  Future<List<dynamic>> getAvailableDestinations() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/routes/destinations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener destinos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<RouteModel> calculateRoute({
    required LatLng origin,
    required String destinationId,
    required String vehicleId,
    required String routeType,
  }) async {
    try {
      print('Iniciando cálculo de ruta...'); // Debug
      final headers = await _getAuthHeaders();
      print('Headers: $headers'); // Debug

      final originCoordinate = {
        'lat': origin.latitude,
        'lng': origin.longitude,
        'name': 'Mi ubicación'
      };

      final body = {
        'origin': originCoordinate,
        'destinationId': destinationId,
        'vehicleId': vehicleId,
        'routeType': routeType,
      };

      print('Body de la petición: $body'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/routes/calculate'),
        headers: headers,
        body: json.encode(body),
      );

      print('Status code: ${response.statusCode}'); // Debug
      print('Response body length: ${response.body.length}'); // Debug
      print('Response body: ${response.body}'); // Debug

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData.containsKey('route')) {
            print('Datos de ruta encontrados, parseando...'); // Debug
            final routeData = responseData['route'];
            final route = RouteModel.fromJson(routeData);
            print('Ruta parseada exitosamente: ${route.toString()}'); // Debug
            return route;
          } else {
            throw Exception('La respuesta no contiene datos de ruta');
          }
        } catch (e) {
          print('Error al parsear respuesta: $e'); // Debug
          throw Exception('Error al procesar la respuesta del servidor: $e');
        }
      }

      throw Exception(
          'Error del servidor: ${response.statusCode}\n${response.body}');
    } catch (e) {
      print('Error detallado en calculateRoute: $e'); // Debug
      rethrow;
    }
  }

  Future<List<RouteModel>> getRouteHistory() async {
    try {
      print('Obteniendo historial de rutas...'); // Debug
      final headers = await _getAuthHeaders();
      print('Headers para historial: $headers'); // Debug

      final response = await http.get(
        Uri.parse('$baseUrl/routes/history'),
        headers: headers,
      );

      print('Status code historial: ${response.statusCode}'); // Debug
      print('Response body historial: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        List<dynamic> routes = json.decode(response.body);
        return routes.map((route) {
          try {
            return RouteModel.fromJson(route);
          } catch (e) {
            print('Error al parsear ruta: $route'); // Debug
            print('Error: $e'); // Debug
            rethrow;
          }
        }).toList();
      } else {
        throw Exception(
            'Error al obtener historial: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Error en getRouteHistory: $e'); // Debug
      throw Exception('Error al obtener historial: $e');
    }
  }

  Future<void> completeRoute(String routeId) async {
    try {
      print('Completando ruta: $routeId'); // Debug
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/routes/$routeId/complete'),
        headers: headers,
      );

      print('Status code complete: ${response.statusCode}'); // Debug
      print('Response body complete: ${response.body}'); // Debug

      if (response.statusCode != 200) {
        throw Exception(
            'Error al completar ruta: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Error en completeRoute: $e'); // Debug
      throw Exception('Error al completar ruta: $e');
    }
  }

  Future<void> cancelRoute(String routeId) async {
    try {
      print('Cancelando ruta: $routeId'); // Debug
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/routes/$routeId/cancel'),
        headers: headers,
      );

      print('Status code cancel: ${response.statusCode}'); // Debug
      print('Response body cancel: ${response.body}'); // Debug

      if (response.statusCode != 200) {
        throw Exception(
            'Error al cancelar ruta: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Error en cancelRoute: $e'); // Debug
      throw Exception('Error al cancelar ruta: $e');
    }
  }
}
