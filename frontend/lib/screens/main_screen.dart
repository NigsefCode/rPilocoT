import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'destination_screen.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  User? _user;

  // Inicializar _widgetOptions directamente en lugar de usar late
  final List<Widget> _widgetOptions = [
    const HomeScreen(),
    const DestinationScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted && user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal
          IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),

          // Barra de navegación
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  height: 65,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    _buildNavDestination(
                      icon: Icons.home_rounded,
                      label: 'Inicio',
                      index: 0,
                    ),
                    _buildNavDestination(
                      icon: Icons.map_rounded,
                      label: 'Rutas',
                      index: 1,
                    ),
                    _buildNavDestination(
                      icon: Icons.settings_rounded,
                      label: 'Ajustes',
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  NavigationDestination _buildNavDestination({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      label: label,
    );
  }
}
