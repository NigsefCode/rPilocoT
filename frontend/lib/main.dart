import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/vehicle_questionnaire_screen.dart';
import 'theme/theme.dart'; // Importa el archivo de tema
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import './services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Prueba de autenticación anónima
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    print("Usuario anónimo ID: ${userCredential.user?.uid}");
    String? token = await userCredential.user?.getIdToken();
    print("Token: $token");
  } catch (e) {
    print("Error de autenticación: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: FirebaseService.getFirebaseToken(),
      builder: (context, snapshot) {
        print('Firebase Token: ${snapshot.data}'); // Para depuración
        if (snapshot.hasData) {
          print('Token obtenido: ${snapshot.data}');
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
        }

        return MaterialApp(
          title: 'rPilocoT',
          theme: AppTheme.darkTheme,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/main': (context) => MainScreen(),
            '/vehicle-questionnaire': (context) =>
                const VehicleQuestionnaireScreen(),
          },
        );
      },
    );
  }
}
