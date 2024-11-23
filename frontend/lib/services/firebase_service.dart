import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static Future<String?> getFirebaseToken() async {
    try {
      print('Obteniendo el token de Firebase...');
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('No hay un usuario autenticado actualmente.');
        return null;
      }

      String? token = await user.getIdToken();
      print('Token de Firebase obtenido: ${token?.substring(0, 20)}...'); // Para asegurar que el token fue obtenido
      return token;
    } catch (e) {
      print('Error al obtener el token de Firebase: $e');
      return null;
    }
  }
}
