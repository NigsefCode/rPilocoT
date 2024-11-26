import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import 'auth_service.dart';

class VehicleService {
  final String baseUrl = 'http://10.0.2.2:5000/api/vehicles';
  //final String baseUrl = 'http://localhost:5000/api/vehicles';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener vehículo por ID
  Future<Vehicle> getVehicleById(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Vehicle.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load vehicle');
    } catch (e) {
      print('Error getting vehicle: $e');
      rethrow;
    }
  }

  // Obtener vehículo activo
  Future<Vehicle?> getActiveVehicle() async {
    try {
      final vehicles = await getUserVehicles();
      if (vehicles.isEmpty) return null;
      // Por ahora retornamos el primer vehículo
      // Posteriormente podrías implementar una lógica para marcar un vehículo como activo
      return vehicles.first;
    } catch (e) {
      print('Error getting active vehicle: $e');
      return null;
    }
  }

  Future<List<Vehicle>> getUserVehicles() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Vehicle.fromJson(json)).toList();
      }
      throw Exception('Failed to load vehicles');
    } catch (e) {
      print('Error getting vehicles: $e');
      rethrow;
    }
  }

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(vehicle.toJson()),
      );

      if (response.statusCode == 201) {
        return Vehicle.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to add vehicle');
    } catch (e) {
      print('Error adding vehicle: $e');
      rethrow;
    }
  }

  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/${vehicle.id}'),
        headers: headers,
        body: json.encode(vehicle.toJson()),
      );

      if (response.statusCode == 200) {
        return Vehicle.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to update vehicle');
    } catch (e) {
      print('Error updating vehicle: $e');
      rethrow;
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete vehicle');
      }
    } catch (e) {
      print('Error deleting vehicle: $e');
      rethrow;
    }
  }
}
