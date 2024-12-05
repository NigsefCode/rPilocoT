import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../services/vehicle_service.dart';
import './route_details_screen.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen>
    with AutomaticKeepAliveClientMixin {
  final LocationService _locationService = LocationService();
  final RouteService _routeService = RouteService();
  final VehicleService _vehicleService = VehicleService();
  List<dynamic> _destinations = [];
  String? _selectedDestination;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final destinations = await _routeService.getAvailableDestinations();

      if (mounted) {
        setState(() {
          _destinations = destinations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al cargar datos iniciales');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Explora los Destinos',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona tu playa favorita',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de destinos
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: 16 + bottomPadding + 80,
                  left: 16,
                  right: 16,
                ),
                itemCount: _destinations.length,
                itemBuilder: (context, index) {
                  final destination = _destinations[index];
                  String imageName = '';
                  // Determinar qué imagen usar según el destino
                  switch (destination['id']) {
                    case 'constitucion':
                      imageName = 'constitucion.jpg';
                      break;
                    case 'iloca':
                      imageName = 'iloca.jpg';
                      break;
                    case 'pichilemu':
                      imageName = 'pichilemu.jpg';
                      break;
                  }
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(
                            () => _selectedDestination = destination['id']);
                        _showRouteOptions(destination);
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              image: DecorationImage(
                                image: AssetImage('assets/images/$imageName'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        destination['name'],
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${destination['distanceFromTalca']} km',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  destination['description'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteOptions(dynamic destination) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tipo de ruta a ${destination['name']}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _calculateRoute(destination, 'optimal'),
                icon: const Icon(Icons.eco),
                label: const Text('Ruta más económica'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _calculateRoute(destination, 'fastest'),
                icon: const Icon(Icons.speed),
                label: const Text('Ruta más rápida'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _calculateRoute(dynamic destination, String routeType) async {
    Navigator.pop(context); // Cerrar el bottom sheet actual

    // Mostrar diálogo de selección de origen
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecciona el punto de partida',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Ubicación actual
              _buildOriginOption(
                context,
                'Mi Ubicación Actual',
                'Usar GPS',
                Icons.my_location,
                () async {
                  Navigator.pop(context);
                  final location = await _locationService.getCurrentLocation();
                  if (!mounted) return;
                  await _proceedWithRoute(
                    destination,
                    routeType,
                    LatLng(location.lat, location.lng),
                  );
                },
              ),
              const Divider(height: 24),
              // Puntos predefinidos
              _buildOriginOption(
                context,
                'Plaza de Armas',
                'Centro de Talca',
                Icons.location_city,
                () {
                  Navigator.pop(context);
                  _proceedWithRoute(
                    destination,
                    routeType,
                    const LatLng(-35.4250, -71.6539),
                  );
                },
              ),
              _buildOriginOption(
                context,
                'Mall Plaza Maule',
                'Centro comercial',
                Icons.shopping_bag,
                () {
                  Navigator.pop(context);
                  _proceedWithRoute(
                    destination,
                    routeType,
                    const LatLng(-35.4276, -71.6555),
                  );
                },
              ),
              _buildOriginOption(
                context,
                'Terminal de Buses',
                'Terminal Regional',
                Icons.directions_bus,
                () {
                  Navigator.pop(context);
                  _proceedWithRoute(
                    destination,
                    routeType,
                    const LatLng(-35.4303, -71.6672),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _proceedWithRoute(
    dynamic destination,
    String routeType,
    LatLng originLocation,
  ) async {
    try {
      final activeVehicle = await _vehicleService.getActiveVehicle();

      if (activeVehicle == null || activeVehicle.id == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona un vehículo válido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteDetailsScreen(
            destination: destination,
            routeType: routeType,
            origin: originLocation,
            vehicleId: activeVehicle.id!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al calcular ruta: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => _calculateRoute(destination, routeType),
          ),
        ),
      );
    }
  }
}
