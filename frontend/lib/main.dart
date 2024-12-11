import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/vehicle_questionnaire_screen.dart';
import 'screens/route_details_screen.dart';
import 'theme/theme.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Maneja los mensajes en segundo plano.
  print('Mensaje en segundo plano recibido: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseSafely();

  // Configuración del manejador de mensajes en segundo plano.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Obtener e imprimir el token FCM
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print('Token FCM desde main: $token');
  } catch (e) {
    print('Error al obtener el token FCM: $e');
  }

  runApp(const MyApp());
}

Future<void> _initializeFirebaseSafely() async {
  try {
    print('Iniciando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente.');

    // Configurar Firebase Messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicitar permisos para notificaciones
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permisos de notificación: ${settings.authorizationStatus}');

    // Configurando listeners para notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida en primer plano: ${message.notification?.title}');
    });
  } catch (e) {
    if (e
        .toString()
        .contains('A Firebase App named "[DEFAULT]" already exists')) {
      print('Firebase ya está inicializado.');
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
            theme: themeProvider.isDarkMode
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/main': (context) => const MainScreen(),
              '/vehicle-questionnaire': (context) =>
                  const VehicleQuestionnaireScreen(),
            },
            // Agregar manejo de rutas con parámetros
            onGenerateRoute: (settings) {
              if (settings.name == '/route-details') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => RouteDetailsScreen(
                    destination: args['destination'],
                    routeType: args['routeType'],
                    origin: args['origin'],
                    vehicleId: args['vehicleId'],
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
