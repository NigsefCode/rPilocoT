import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../models/coordinate.dart';
import './route_details_screen.dart';
import '../services/vehicle_service.dart';
import '../widgets/origin_selector_dialog.dart';

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
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  List<dynamic> _destinations = [];
  String? _selectedDestination;
  bool _isLoading = true;

  // Mantener el estado vivo cuando se cambia de tab
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final location = await _locationService.getCurrentLocation();
      final destinations = await _routeService.getAvailableDestinations();

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(location.lat, location.lng);
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
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false, // Para el navbar
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Explora los destinos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Mapa contenido
            Container(
              height: screenHeight * 0.3, // 30% de la altura de la pantalla
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation ??
                            const LatLng(-35.4250, -71.6539),
                        zoom: 11,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: FloatingActionButton.small(
                        onPressed: _goToCurrentLocation,
                        backgroundColor: theme.colorScheme.surface,
                        child: Icon(
                          Icons.my_location,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista de destinos
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: 16 + bottomPadding + 80, // Espacio para el navbar
                  left: 16,
                  right: 16,
                ),
                itemCount: _destinations.length,
                itemBuilder: (context, index) {
                  final destination = _destinations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(
                            () => _selectedDestination = destination['id']);
                        _showRouteOptions(destination);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.beach_access,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    destination['name'],
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${destination['distanceFromTalca']} km',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              destination['description'],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
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

  void _goToCurrentLocation() {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
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
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _calculateRoute(dynamic destination, String routeType) async {
    Navigator.pop(context); // Cerrar el bottom sheet actual

    // Mostrar diálogo de selección de origen
    await showDialog(
      context: context,
      builder: (context) => OriginSelectorDialog(
        onLocationSelected: (LatLng selectedOrigin) async {
          Navigator.pop(context); // Cerrar el diálogo

          try {
            print('1. Iniciando cálculo de ruta...'); // Debug
            print('Destino seleccionado: $destination'); // Debug
            print('Tipo de ruta: $routeType'); // Debug
            print('Origen seleccionado: $selectedOrigin'); // Debug

            // Obtener vehículo activo
            print('2. Obteniendo vehículo activo...'); // Debug
            final activeVehicle = await _vehicleService.getActiveVehicle();
            print('Vehículo activo: ${activeVehicle?.toJson()}'); // Debug

            if (activeVehicle == null || activeVehicle.id == null) {
              print('Error: No hay vehículo activo válido'); // Debug
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecciona un vehículo válido'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            print('3. Vehículo validado correctamente'); // Debug
            print('ID del vehículo: ${activeVehicle.id}'); // Debug

            if (!mounted) return;

            print('4. Navegando a la pantalla de detalles...'); // Debug
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailsScreen(
                  destination: destination,
                  routeType: routeType,
                  origin: selectedOrigin,
                  vehicleId: activeVehicle.id!,
                ),
              ),
            );

            print('5. Navegación completada exitosamente'); // Debug
          } catch (e, stackTrace) {
            print('ERROR en _calculateRoute:'); // Debug
            print('Tipo de error: ${e.runtimeType}'); // Debug
            print('Mensaje de error: $e'); // Debug
            print('Stack trace: $stackTrace'); // Debug

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
        },
      ),
    );
  }
}
