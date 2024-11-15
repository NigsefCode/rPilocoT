// lib/screens/routes/routes_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../services/config_service.dart';
import '../../services/map_service.dart';
import '../../services/route_service.dart';
import 'widgets/route_header.dart';
import 'widgets/origin_card.dart';
import 'widgets/destination_card.dart';
import 'widgets/route_summary.dart';
import 'widgets/route_option_card.dart';
import 'widgets/google_map_widget.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final MapService _mapService = MapService();
  final AuthService _authService = AuthService();
  late RouteService _routeService;
  bool _isServiceInitialized = false;

  GoogleMapController? _mapController;
  bool _isMapInitialized = false;
  bool _isMapReady = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String? selectedDestination;
  bool isOptimalRoute = true;
  Map<String, dynamic>? routeSummary;
  Map<String, double>? _fuelPrices;
  String? _apiKey;
  bool _isLoading = true;
  String? _selectedVehicleId;
  bool _disposed = false;

  static const _coordinates = {
    'Talca': LatLng(-35.4264, -71.6553),
    'Pichilemu': LatLng(-34.3869, -72.0033),
    'Iloca': LatLng(-34.9301, -72.1795),
    'Constitución': LatLng(-35.3335, -72.4156),
  };

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _disposed = true;
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    try {
      _apiKey = await ConfigService.getGoogleMapsApiKey();
      print('API key loaded: ${_apiKey != null}');
    } catch (e) {
      print('Error loading API key: $e');
      rethrow;
    }
  }

  Future<void> _initializeMap() async {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('talca'),
          position: _coordinates['Talca']!,
          infoWindow: const InfoWindow(
            title: 'Talca',
            snippet: 'Punto de partida',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      };
    });
  }

  Future<void> _loadUserVehicle() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/vehicles/default'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final vehicle = json.decode(response.body);
        setState(() => _selectedVehicleId = vehicle['_id']);
      }
    } catch (e) {
      print('Error loading vehicle: $e');
      rethrow;
    }
  }

  Future<void> _calculateRoute(String destination) async {
    if (_selectedVehicleId == null || _disposed || !_isServiceInitialized) {
      print('No se puede calcular la ruta: servicios no inicializados');
      return;
    }

    setState(() {
      _isLoading = true;
      _polylines = {};
    });

    try {
      final routeData = await _routeService.calculateRoute(
        destination: destination.toUpperCase(),
        vehicleId: _selectedVehicleId!,
        isOptimalRoute: isOptimalRoute,
      );

      if (!mounted) return;

      final destinationLatLng = LatLng(
        RouteService.DESTINATIONS[destination.toUpperCase()]!['coordinates']
            ['lat'],
        RouteService.DESTINATIONS[destination.toUpperCase()]!['coordinates']
            ['lng'],
      );

      setState(() {
        _markers = _mapService.createRouteMarkers(
          origin: RouteService.getTalcaLocation(),
          destination: destinationLatLng,
          stops: List<LatLng>.from(routeData['mapData']['waypoints'] ?? []),
          destinationName: destination,
        );

        final points =
            _mapService.decodePolyline(routeData['mapData']['polyline']);
        _polylines = _mapService.createRoutePolyline(points);

        routeSummary = {
          'distance': '${routeData['distance'].toStringAsFixed(1)} km',
          'time': '${routeData['duration']} min',
          'fuel': '${routeData['fuelConsumption'].toStringAsFixed(1)} L',
          'cost': '\$${_formatCurrency(routeData['estimatedCost'])}',
          'stops': routeData['stops'] ?? [],
          'tips': routeData['tips'] ?? [],
          'trafficLevel': routeData['trafficLevel'] ?? 'medium',
        };
      });

      // Ajustar la cámara del mapa
      if (_mapController != null && routeData['mapData']['bounds'] != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(routeData['mapData']['bounds'], 50),
        );
      }
    } catch (e) {
      print('Error calculando ruta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular la ruta: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _initializeScreen() async {
    try {
      setState(() => _isLoading = true);

      // Inicializar servicios en paralelo
      await Future.wait([
        _initializeServices(),
        _loadApiKey(),
        _initializeMap(),
        _loadUserVehicle(),
      ]);

      if (!_disposed) {
        setState(() {
          _isLoading = false;
          _isServiceInitialized = true;
        });
      }
    } catch (e) {
      print('Error in initialization: $e');
      if (!_disposed && mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al inicializar: $e')),
        );
      }
    }
  }

  Future<void> _initializeServices() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }
      _routeService = RouteService(token: token);
    } catch (e) {
      print('Error inicializando servicios: $e');
      throw e;
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  void onDestinationSelected(String destination) {
    if (_disposed) return;
    // Asegurarte de que el destino esté en mayúsculas y sea uno de los válidos
    final normalizedDestination = destination.toUpperCase();
    setState(() => selectedDestination = normalizedDestination);
    _calculateRoute(normalizedDestination);
  }

  void onRouteTypeChanged(bool isOptimal) {
    if (_disposed) return;
    setState(() => isOptimalRoute = isOptimal);
    if (selectedDestination != null) {
      _calculateRoute(selectedDestination!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isMapInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RouteHeader(fuelPrices: _fuelPrices),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GoogleMapWidget(
                    markers: _markers,
                    polylines: _polylines,
                    isLoading: _isLoading,
                    initialPosition: _coordinates['Talca']!,
                    onMapCreated: (controller) {
                      print('Mapa creado');
                      if (!_disposed) {
                        setState(() {
                          _mapController = controller;
                          _isMapInitialized = true;
                          _isMapReady = true;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Origen y Destino',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const OriginCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Selecciona tu Destino',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DestinationCard(
                          name: 'Pichilemu',
                          description: 'La capital del surf',
                          imageUrl: 'assets/images/pichilemu.jpg',
                          isSelected: selectedDestination == 'Pichilemu',
                          onSelected: () => onDestinationSelected('Pichilemu'),
                          stops:
                              RouteService.DESTINATIONS['PICHILEMU']!['stops'],
                          distance: '198 km',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DestinationCard(
                          name: 'Iloca',
                          description: 'Playa familiar',
                          imageUrl: 'assets/images/iloca.jpg',
                          isSelected: selectedDestination == 'Iloca',
                          onSelected: () => onDestinationSelected('Iloca'),
                          stops: RouteService.DESTINATIONS['ILOCA']!['stops'],
                          distance: '108 km',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DestinationCard(
                    name: 'Constitución',
                    description: 'Ciudad costera histórica',
                    imageUrl: 'assets/images/constitucion.jpg',
                    isSelected: selectedDestination == 'Constitución',
                    onSelected: () => onDestinationSelected('Constitución'),
                    stops: RouteService.DESTINATIONS['CONSTITUCION']!['stops'],
                    distance: '111 km',
                    fullWidth: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tipo de Ruta',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RouteOptionCard(
                          title: 'Óptima',
                          icon: Icons.eco,
                          description: 'Menor consumo de combustible',
                          isSelected: isOptimalRoute,
                          onSelected: () => onRouteTypeChanged(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RouteOptionCard(
                          title: 'Rápida',
                          icon: Icons.speed,
                          description: 'Menor tiempo de viaje',
                          isSelected: !isOptimalRoute,
                          onSelected: () => onRouteTypeChanged(false),
                        ),
                      ),
                    ],
                  ),
                  if (routeSummary != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Resumen de Ruta',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    RouteSummary(
                      routeData: routeSummary,
                      isOptimalRoute: isOptimalRoute,
                      onRouteTypeChanged: onRouteTypeChanged,
                      onNavigationStart: () {
                        if (selectedDestination != null && !_disposed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Iniciando navegación...'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
