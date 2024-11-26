// services/fuel_price_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fuel_price.dart';
import 'config_service.dart';

class FuelPriceService {
  final String baseUrl = ConfigService.baseUrl;
  final String? token;

  FuelPriceService({this.token});

  Future<Map<String, double>> getCurrentPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes/fuel-prices'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, value.toDouble()));
      } else {
        throw Exception('Error al obtener precios');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Solo para administradores
  Future<void> updateFuelPrice(String fuelType, double newPrice) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/routes/fuel-prices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'fuelType': fuelType,
          'price': newPrice,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar precio');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
