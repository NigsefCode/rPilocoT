// lib/models/route_model.dart
class Route {
  final String id;
  final String origin;
  final String destination;
  final double distance;
  final double duration;
  final double fuelConsumption;
  final String routeType;
  final String polyline;
  final String trafficLevel;
  final double estimatedCost;
  final DateTime createdAt;

  Route({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distance,
    required this.duration,
    required this.fuelConsumption,
    required this.routeType,
    required this.polyline,
    required this.trafficLevel,
    required this.estimatedCost,
    required this.createdAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['_id'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      distance: json['distance']?.toDouble() ?? 0.0,
      duration: json['duration']?.toDouble() ?? 0.0,
      fuelConsumption: json['fuelConsumption']?.toDouble() ?? 0.0,
      routeType: json['routeType'] ?? '',
      polyline: json['polyline'] ?? '',
      trafficLevel: json['trafficLevel'] ?? 'medium',
      estimatedCost: json['estimatedCost']?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'origin': origin,
      'destination': destination,
      'distance': distance,
      'duration': duration,
      'fuelConsumption': fuelConsumption,
      'routeType': routeType,
      'polyline': polyline,
      'trafficLevel': trafficLevel,
      'estimatedCost': estimatedCost,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
