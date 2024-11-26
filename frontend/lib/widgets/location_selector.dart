import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../models/coordinate.dart';

class LocationSelector extends StatelessWidget {
  final Function(LatLng) onLocationSelected;
  final LocationService locationService;

  const LocationSelector({
    super.key,
    required this.onLocationSelected,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    // Convertir getDefaultOrigins() a Future
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
              onTap: () async {
                final location = await locationService.getCurrentLocation();
                onLocationSelected(LatLng(location.lat, location.lng));
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
