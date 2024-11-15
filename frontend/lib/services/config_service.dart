import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class ConfigService {
  static const String baseUrl = 'http://localhost:5000/api';
  static final AuthService _authService = AuthService();

  static Future<String> getGoogleMapsApiKey() async {
    try {
      print('Obteniendo token...');
      final token = await _authService.getToken();
      //print('Token obtenido: $token');

      print('Haciendo petición a la API...');
      final response = await http.get(
        Uri.parse('$baseUrl/config/google-maps'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      //print('Respuesta recibida: ${response.statusCode}');
      //print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['apiKey'];
      } else {
        throw Exception(
            'Error al obtener API key: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error detallado: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
