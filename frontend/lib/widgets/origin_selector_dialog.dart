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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecciona el punto de partida',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Opciones de origen
            _OriginOption(
              icon: Icons.location_city,
              title: 'Plaza de Armas de Talca',
              subtitle: 'Centro de la ciudad',
              onTap: () =>
                  onLocationSelected(const LatLng(-35.426262, -71.655764)),
              theme: theme,
            ),
            _OriginOption(
              icon: Icons.shopping_basket,
              title: 'Mall Plaza Maule',
              subtitle: 'Centro comercial',
              onTap: () =>
                  onLocationSelected(const LatLng(-35.427919, -71.673320)),
              theme: theme,
            ),
            _OriginOption(
              icon: Icons.directions_bus,
              title: 'Terminal de Buses',
              subtitle: 'Terminal Regional de Talca',
              onTap: () =>
                  onLocationSelected(const LatLng(-35.430916, -71.666989)),
              theme: theme,
            ),
            _OriginOption(
              icon: Icons.school,
              title: 'Universidad de Talca',
              subtitle: 'Campus Lircay',
              onTap: () =>
                  onLocationSelected(const LatLng(-35.404722, -71.636667)),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _OriginOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ThemeData theme;

  const _OriginOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          onTap();
          Navigator.pop(context);
        },
      ),
    );
  }
}
