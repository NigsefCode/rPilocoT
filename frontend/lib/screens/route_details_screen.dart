import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';

class RouteDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  final String routeType;
  final LatLng origin;
  final String vehicleId;

  const RouteDetailsScreen({
    Key? key,
    required this.destination,
    required this.routeType,
    required this.origin,
    required this.vehicleId,
  }) : super(key: key);

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen>
    with WidgetsBindingObserver {
  final RouteService _routeService = RouteService();
  RouteModel? _route;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  String? _errorMessage;
  GoogleMapController? _mapController;
  bool _isMapReady = false;
  bool _isDisposed = false; // Para verificar si el widget está desmontado.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _calculateRoute();
  }

  @override
  void dispose() {
    _isDisposed = true; // Marca el widget como desmontado.
    WidgetsBinding.instance.removeObserver(this);
    _disposeMapController();
    super.dispose();
  }

  void _disposeMapController() {
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print("App en pausa, controlador no dispuesto.");
    }
  }

  Future<void> _calculateRoute() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final calculatedRoute = await _routeService.calculateRoute(
        origin: widget.origin,
        destinationId: widget.destination['id'],
        vehicleId: widget.vehicleId,
        routeType: widget.routeType,
      );

      final markers = {
        Marker(
          markerId: const MarkerId('origin'),
          position: widget.origin,
          infoWindow: const InfoWindow(title: 'Origen'),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            widget.destination['coordinates']['lat'],
            widget.destination['coordinates']['lng'],
          ),
          infoWindow: InfoWindow(title: widget.destination['name']),
        ),
      };

      List<LatLng> polylinePoints = [];
      try {
        final points =
            PolylinePoints().decodePolyline(calculatedRoute.polyline);
        polylinePoints = points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      } catch (e) {
        print('Error decodificando polyline: $e');
      }

      final polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: Theme.of(context).colorScheme.primary,
          width: 5,
          points: polylinePoints,
        ),
      };

      if (mounted && !_isDisposed) {
        setState(() {
          _route = calculatedRoute;
          _markers = markers;
          _polylines = polylines;
          _isLoading = false;
        });

        if (_isMapReady) {
          _fitMapToRoute(polylinePoints);
        }
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Error al calcular la ruta: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _fitMapToRoute(List<LatLng> points) {
    if (points.isEmpty || _mapController == null || _isDisposed) return;

    try {
      LatLngBounds bounds = LatLngBounds(
        southwest: points.reduce(
          (value, element) => LatLng(
            value.latitude < element.latitude
                ? value.latitude
                : element.latitude,
            value.longitude < element.longitude
                ? value.longitude
                : element.longitude,
          ),
        ),
        northeast: points.reduce(
          (value, element) => LatLng(
            value.latitude > element.latitude
                ? value.latitude
                : element.latitude,
            value.longitude > element.longitude
                ? value.longitude
                : element.longitude,
          ),
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0),
      );
    } catch (e) {
      print('Error ajustando el mapa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        _disposeMapController();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _disposeMapController();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text('Ruta a ${widget.destination['name']}'),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _calculateRoute,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: widget.origin,
                            zoom: 12,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            if (!_isDisposed) {
                              setState(() {
                                _mapController = controller;
                                _isMapReady = true;
                                if (_route != null) {
                                  _fitMapToRoute(_polylines.first.points);
                                }
                              });
                            }
                          },
                          markers: _markers,
                          polylines: _polylines,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.routeType == 'optimal'
                                    ? 'Ruta más económica'
                                    : 'Ruta más rápida',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_route != null) ...[
                                _InfoCard(
                                  children: [
                                    _InfoRow(
                                      icon: Icons.straighten,
                                      label: 'Distancia',
                                      value:
                                          '${_route!.distance.toStringAsFixed(1)} km',
                                    ),
                                    _InfoRow(
                                      icon: Icons.timer,
                                      label: 'Tiempo estimado',
                                      value:
                                          '${(_route!.duration).toStringAsFixed(0)} min',
                                    ),
                                    _InfoRow(
                                      icon: Icons.local_gas_station,
                                      label: 'Consumo estimado',
                                      value:
                                          '${_route!.fuelConsumption.toStringAsFixed(1)} L',
                                    ),
                                    _InfoRow(
                                      icon: Icons.attach_money,
                                      label: 'Costo estimado',
                                      value:
                                          '\$${_route!.estimatedCost.toStringAsFixed(0)}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Implementar inicio de navegación
                                  },
                                  icon: const Icon(Icons.navigation),
                                  label: const Text('Iniciar navegación'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Implementar guardado de ruta
                                  },
                                  icon: const Icon(Icons.bookmark_border),
                                  label: const Text('Guardar ruta'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyLarge),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
