import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OriginSelectorDialog extends StatelessWidget {
  final Function(LatLng) onLocationSelected;

  const OriginSelectorDialog({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecciona tu punto de partida',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Ubicación actual (Talca por defecto)
            ListTile(
              leading:
                  Icon(Icons.location_city, color: theme.colorScheme.primary),
              title: const Text('Talca Centro'),
              subtitle: const Text('Plaza de Armas'),
              onTap: () {
                onLocationSelected(const LatLng(-35.4250, -71.6539));
                Navigator.pop(context);
              },
            ),
            // Mall
            ListTile(
              leading: Icon(Icons.store, color: theme.colorScheme.primary),
              title: const Text('Mall Plaza Maule'),
              subtitle: const Text('Centro comercial'),
              onTap: () {
                onLocationSelected(const LatLng(-35.4276, -71.6555));
                Navigator.pop(context);
              },
            ),
            // Terminal
            ListTile(
              leading:
                  Icon(Icons.directions_bus, color: theme.colorScheme.primary),
              title: const Text('Terminal de Buses'),
              subtitle: const Text('Terminal Regional'),
              onTap: () {
                onLocationSelected(const LatLng(-35.4303, -71.6672));
                Navigator.pop(context);
              },
            ),
            // Universidad
            ListTile(
              leading: Icon(Icons.school, color: theme.colorScheme.primary),
              title: const Text('Universidad de Talca'),
              subtitle: const Text('Campus Lircay'),
              onTap: () {
                onLocationSelected(const LatLng(-35.4022, -71.6193));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
