import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/vehicle_questionnaire_screen.dart';
import 'theme/theme.dart'; // Importa el archivo de tema
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseSafely();
  runApp(const MyApp());
}

Future<void> _initializeFirebaseSafely() async {
  try {
    print('Iniciando Firebase...'); // Log para verificar que se inicia la inicialización
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente.'); // Log para confirmar la inicialización exitosa
  } catch (e) {
    // Si ya existe una instancia, capturamos el error y lo ignoramos
    if (e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
      print('Firebase ya está inicializado, no se requiere inicializar nuevamente.');
    } else {
      print('Error al inicializar Firebase: $e'); // Log de error para cualquier otro problema
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Construyendo MyApp widget...'); // Log para confirmar que MyApp se está construyendo
    return MaterialApp(
      title: 'rPilocoT',
      theme: AppTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) {
          print('Navegando a la pantalla de login...'); // Log para verificar la navegación
          return const LoginScreen();
        },
        '/register': (context) {
          print('Navegando a la pantalla de registro...'); // Log para verificar la navegación
          return const RegisterScreen();
        },
        '/main': (context) {
          print('Navegando a la pantalla principal...'); // Log para verificar la navegación
          return const MainScreen();
        },
        '/vehicle-questionnaire': (context) {
          print('Navegando a la pantalla del cuestionario del vehículo...'); // Log para verificar la navegación
          return const VehicleQuestionnaireScreen();
        },
      },
    );
  }
}
