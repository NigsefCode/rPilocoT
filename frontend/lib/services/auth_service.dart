import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  //final String baseUrl = 'http://10.0.2.2:5000/api/auth';
  final String baseUrl = 'http://localhost:5000/api/auth';
  final storage = FlutterSecureStorage();
  User? _currentUser;

  // Getter para el usuario actual
  User? get currentUser => _currentUser;

  Future<String?> getToken() async {
    try {
      final token = await storage.read(key: 'token');
      print('Token obtenido: ${token?.substring(0, 20)}...'); // Para debug
      return token;
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        await storage.write(key: 'token', value: responseData['token']);

        // Crear instancia de User con los datos
        _currentUser = User.fromJson(responseData['user']);
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print('Intentando login con email: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await storage.write(key: 'token', value: responseData['token']);
        _currentUser = User.fromJson(responseData['user']);
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el inicio de sesión');
      }
    } catch (e) {
      print('Login error detallado: $e');
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = User.fromJson(userData);
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    _currentUser = null;
  }

  Future<bool> updateQuestionnaireStatus() async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/questionnaire-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await getCurrentUser(); // Actualiza el usuario actual
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateName(String newName) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/update-name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'name': newName}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _currentUser = User.fromJson(responseData['user']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating name: $e');
      return false;
    }
  }

  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      final token = await storage.read(key: 'token');
      print('Token disponible para actualización: ${token != null}');

      final response = await http.put(
        Uri.parse('$baseUrl/update-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      print('Update password response status: ${response.statusCode}');
      print('Update password response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Error al actualizar la contraseña');
      }

      await logout();
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }
}
