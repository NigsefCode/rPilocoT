// lib/services/map_service.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';

class MapService {
  final PolylinePoints polylinePoints = PolylinePoints();

  List<LatLng> decodePolyline(String encodedString) {
    List<PointLatLng> points = polylinePoints.decodePolyline(encodedString);
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  LatLngBounds getBoundsForPoints(List<LatLng> points) {
    if (points.isEmpty) {
      // Bounds por defecto centrados en Talca
      return LatLngBounds(
        southwest: const LatLng(-35.4272, -71.6554),
        northeast: const LatLng(-34.3867, -72.0033),
      );
    }

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // Agregar padding al bounds
    return LatLngBounds(
      southwest: LatLng(minLat - 0.05, minLng - 0.05),
      northeast: LatLng(maxLat + 0.05, maxLng + 0.05),
    );
  }

  Set<Marker> createRouteMarkers({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> stops,
    required String destinationName,
  }) {
    Set<Marker> markers = {};

    // Marcador de origen (Talca)
    markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: origin,
        infoWindow:
            const InfoWindow(title: 'Talca', snippet: 'Punto de partida'),
      ),
    );

    // Marcadores de paradas
    for (int i = 0; i < stops.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: stops[i],
          infoWindow: InfoWindow(
            title: 'Parada ${i + 1}',
            snippet: 'Punto de descanso recomendado',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Marcador de destino
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(
          title: destinationName,
          snippet: 'Destino final',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    return markers;
  }

  Set<Polyline> createRoutePolyline(List<LatLng> points) {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: Colors.blue, // Cambiado a Colors.blue
        width: 5,
      ),
    };
  }
}
