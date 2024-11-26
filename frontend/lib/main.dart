import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/vehicle_questionnaire_screen.dart';
import 'theme/theme.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseSafely();
  runApp(const MyApp());
}

Future<void> _initializeFirebaseSafely() async {
  try {
    print('Iniciando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente.');
  } catch (e) {
    if (e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
      print('Firebase ya estÃ¡ inicializado.');
    } else {
      print('Error al inicializar Firebase: $e');
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'rPilocoT',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/main': (context) => const MainScreen(),
              '/vehicle-questionnaire': (context) => const VehicleQuestionnaireScreen(),
            },
          );
        },
      ),
    );
  }
}