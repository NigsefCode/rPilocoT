class RouteModel {
  final String id;
  final String userId;
  final String vehicleId;
  final Map<String, dynamic> origin;
  final Map<String, dynamic> destination;
  final double distance;
  final double duration;
  final double fuelConsumption;
  final String routeType;
  final String polyline;
  final String trafficLevel;
  final double estimatedCost;
  final String status;
  final DateTime? createdAt;

  RouteModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.origin,
    required this.destination,
    required this.distance,
    required this.duration,
    required this.fuelConsumption,
    required this.routeType,
    required this.polyline,
    required this.trafficLevel,
    required this.estimatedCost,
    required this.status,
    this.createdAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    try {
      return RouteModel(
        id: json['_id'] ?? json['id'] ?? '',
        userId: json['userId'] ?? '',
        vehicleId: json['vehicleId'] ?? '',
        origin: Map<String, dynamic>.from(json['origin'] ?? {}),
        destination: Map<String, dynamic>.from(json['destination'] ?? {}),
        distance: (json['distance'] ?? 0).toDouble(),
        duration: (json['duration'] ?? 0).toDouble(),
        fuelConsumption: (json['fuelConsumption'] ?? 0).toDouble(),
        routeType: json['routeType'] ?? '',
        polyline: json['polyline'] ?? '',
        trafficLevel: json['trafficLevel'] ?? 'medium',
        estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
        status: json['status'] ?? 'active',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );
    } catch (e) {
      print('Error parsing RouteModel: $e');
      print('JSON received: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'origin': origin,
      'destination': destination,
      'distance': distance,
      'duration': duration,
      'fuelConsumption': fuelConsumption,
      'routeType': routeType,
      'polyline': polyline,
      'trafficLevel': trafficLevel,
      'estimatedCost': estimatedCost,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RouteModel('
        'id: $id, '
        'distance: $distance km, '
        'duration: $duration min, '
        'fuelConsumption: $fuelConsumption L, '
        'estimatedCost: \$$estimatedCost)';
  }
}
