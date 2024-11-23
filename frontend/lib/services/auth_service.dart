import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias para Firebase Auth
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:5000/api/auth';
  //final String baseUrl = 'http://localhost:5000/api/auth';
  final storage = const FlutterSecureStorage();
  User? _currentUser;

  // Instancia de GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Getter para el usuario actual
  User? get currentUser => _currentUser;

  Future<String?> getToken() async {
    try {
      print('Obteniendo token del almacenamiento seguro...');
      final token = await storage.read(key: 'token');
      if (token != null) {
        print('Token obtenido: ${token.substring(0, 20)}...');
      } else {
        print('No se encontró token almacenado.');
      }
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

  Future<bool> registerGoogleUser(String name, String email) async {
    try {
      print('Intentando registrar el usuario de Google: $name ($email)');
      final response = await http.post(
        Uri.parse('$baseUrl/register-google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
        }),
      );

      print('Respuesta del servidor para registro de Google: ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Guardar token en el almacenamiento seguro si es necesario
        if (responseData['token'] != null) {
          await storage.write(key: 'token', value: responseData['token']);
        }

        // Crear instancia de User con los datos recibidos
        _currentUser = User.fromJson(responseData['user']);
        return true;
      }

      print('Error al registrar el usuario de Google. Código de respuesta: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Google registration error: $e');
      return false;
    }
  }


  Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      print('Iniciando el flujo de autenticación con Google...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('El usuario canceló el inicio de sesión de Google.');
        return null;
      }

      print('Usuario de Google encontrado: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Autenticación de Google completada. Accediendo a credenciales...');

      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Iniciando sesión con Firebase usando credenciales de Google...');
      final firebase_auth.UserCredential userCredential =
          await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);

      print('Inicio de sesión con Firebase completado.');
      String? displayName = userCredential.user?.displayName;
      String? email = userCredential.user?.email;

      if (displayName != null && email != null) {
        print('Registrando usuario de Google en la base de datos: $displayName ($email)');
        final success = await registerGoogleUser(displayName, email);
        if (success) {
          _currentUser = User(name: displayName, email: email);
          print('Usuario registrado exitosamente.');
        } else {
          print('No se pudo registrar el usuario en la base de datos.');
        }
      }

      return userCredential.user;
    } catch (e) {
      print('Error en Google Sign-In: $e');
      return null;
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

  // Logout para ambos tipos de usuario (tradicional y Google)
  Future<void> logout() async {
    try {
      // Eliminar el token almacenado localmente
      await storage.delete(key: 'token');

      // Desconectar al usuario de Google si está logueado con Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // También cerrar sesión de Firebase
      await firebase_auth.FirebaseAuth.instance.signOut(); // Uso del alias 'firebase_auth' para cerrar sesión de Firebase
    } catch (e) {
      print('Error cerrando sesión: $e');
    }
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
