// widgets/route_summary.dart
import 'package:flutter/material.dart';

class RouteSummary extends StatelessWidget {
  final Map<String, dynamic>? routeData;
  final bool isOptimalRoute;
  final Function(bool) onRouteTypeChanged;
  final VoidCallback onNavigationStart;

  const RouteSummary({
    Key? key,
    this.routeData,
    required this.isOptimalRoute,
    required this.onRouteTypeChanged,
    required this.onNavigationStart,
  }) : super(key: key);

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsList(List<String> stops) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stop_circle_outlined,
                  size: 24, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Paradas Recomendadas',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...stops.map((stop) => Padding(
                padding: const EdgeInsets.only(left: 36, bottom: 4),
                child: Text(
                  '• $stop',
                  style: const TextStyle(fontSize: 14),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTipsList(List<String> tips) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, size: 24, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Recomendaciones',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(left: 36, bottom: 4),
                child: Text(
                  '• $tip',
                  style: const TextStyle(fontSize: 14),
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (routeData == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              isOptimalRoute ? 'Ruta Óptima' : 'Ruta más Rápida',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildSummaryRow(
            'Distancia',
            routeData!['distance'],
            Icons.straighten,
          ),
          const Divider(height: 1),
          _buildSummaryRow(
            'Tiempo estimado',
            routeData!['time'],
            Icons.access_time,
          ),
          const Divider(height: 1),
          _buildSummaryRow(
            'Consumo combustible',
            routeData!['fuel'],
            Icons.local_gas_station,
          ),
          const Divider(height: 1),
          _buildSummaryRow(
            'Costo estimado',
            routeData!['cost'],
            Icons.attach_money,
          ),
          if (routeData!['stops'] != null) ...[
            const Divider(height: 1),
            _buildStopsList(List<String>.from(routeData!['stops'])),
          ],
          if (routeData!['tips'] != null) ...[
            const Divider(height: 1),
            _buildTipsList(List<String>.from(routeData!['tips'])),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (routeData!['trafficLevel'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.traffic,
                          color: _getTrafficColor(routeData!['trafficLevel']),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nivel de tráfico: ${_getTrafficText(routeData!['trafficLevel'])}',
                          style: TextStyle(
                            color: _getTrafficColor(routeData!['trafficLevel']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onNavigationStart,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Iniciar Navegación'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrafficColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTrafficText(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 'Bajo';
      case 'medium':
        return 'Medio';
      case 'high':
        return 'Alto';
      default:
        return 'Desconocido';
    }
  }
}
