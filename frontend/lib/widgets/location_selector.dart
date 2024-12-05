import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../models/coordinate.dart';

class LocationSelector extends StatelessWidget {
  final Function(LatLng) onLocationSelected;
  final LocationService locationService;

  // Definir límites de Talca y alrededores
  static const double TALCA_MIN_LAT = -35.5000; // Límite sur
  static const double TALCA_MAX_LAT = -35.3000; // Límite norte
  static const double TALCA_MIN_LNG = -71.7500; // Límite oeste
  static const double TALCA_MAX_LNG = -71.5500; // Límite este

  const LocationSelector({
    super.key,
    required this.onLocationSelected,
    required this.locationService,
  });

  bool _isLocationInTalca(double lat, double lng) {
    return lat >= TALCA_MIN_LAT &&
        lat <= TALCA_MAX_LAT &&
        lng >= TALCA_MIN_LNG &&
        lng <= TALCA_MAX_LNG;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.value(locationService.getDefaultOrigins()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Usar mi ubicación actual'),
              subtitle: const Text('Debe estar en Talca o alrededores'),
              onTap: () async {
                try {
                  final location = await locationService.getCurrentLocation();

                  if (_isLocationInTalca(location.lat, location.lng)) {
                    onLocationSelected(LatLng(location.lat, location.lng));
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tu ubicación actual debe estar en Talca o sus alrededores. Por favor, selecciona un punto de origen predefinido.',
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error al obtener la ubicación. Por favor, selecciona un punto de origen predefinido.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const Divider(),
            ...snapshot.data!.map((origin) {
              final coordinate = origin['coordinate'] as Coordinate;
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(origin['name']),
                subtitle: Text(origin['description']),
                onTap: () => onLocationSelected(
                  LatLng(coordinate.lat, coordinate.lng),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
