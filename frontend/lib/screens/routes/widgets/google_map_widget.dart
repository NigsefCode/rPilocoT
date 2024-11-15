// lib/screens/routes/widgets/google_map_widget.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatefulWidget {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool isLoading;
  final Function(GoogleMapController) onMapCreated;
  final LatLng initialPosition;

  const GoogleMapWidget({
    Key? key,
    required this.markers,
    required this.polylines,
    required this.isLoading,
    required this.onMapCreated,
    required this.initialPosition,
  }) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _controller;
  bool _isMapCreated = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            RepaintBoundary(
              child: AbsorbPointer(
                absorbing: widget.isLoading,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.initialPosition,
                    zoom: 12.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    setState(() {
                      _controller = controller;
                      _isMapCreated = true;
                    });
                    widget.onMapCreated(controller);
                  },
                  markers: widget.markers,
                  polylines: widget.polylines,
                  mapType: MapType.normal,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  trafficEnabled: false,
                  indoorViewEnabled: false,
                  buildingsEnabled: false,
                  liteModeEnabled: false,
                ),
              ),
            ),
            if (widget.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            // Indicador de debug
            if (!_isMapCreated)
              Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Text('Cargando mapa...'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
