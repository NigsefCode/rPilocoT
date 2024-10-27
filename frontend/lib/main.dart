import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/vehicle_questionnaire_screen.dart';
import 'theme/theme.dart'; // Importa el archivo de tema

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rPilocoT',
      theme: AppTheme.darkTheme, // Usa el tema oscuro definido
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) => MainScreen(),
        '/vehicle-questionnaire': (context) =>
            const VehicleQuestionnaireScreen(),
      },
    );
  }
}
