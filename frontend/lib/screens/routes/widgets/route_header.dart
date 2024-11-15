import 'package:flutter/material.dart';
import 'fuel_price.dart';

class RouteHeader extends StatelessWidget {
  final Map<String, double>? fuelPrices;
  final String? selectedDestination; // Nuevo
  final int? totalRoutes; // Nuevo

  const RouteHeader({
    super.key,
    this.fuelPrices,
    this.selectedDestination,
    this.totalRoutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Planifica tu Viaje',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (totalRoutes != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalRoutes rutas',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedDestination != null
                  ? 'Ruta hacia $selectedDestination'
                  : 'Encuentra la mejor ruta a tu destino costero',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            if (fuelPrices != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FuelPriceWidget(
                      fuelType: 'Bencina',
                      price: fuelPrices!['Bencina'] ?? 0,
                      lastUpdate: DateTime.now(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FuelPriceWidget(
                      fuelType: 'Petróleo',
                      price: fuelPrices!['Petróleo'] ?? 0,
                      lastUpdate: DateTime.now(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
