// lib/models/coordinate.dart
class Coordinate {
  final double lat;
  final double lng;
  final String name;

  Coordinate({
    required this.lat,
    required this.lng,
    required this.name,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'name': name,
    };
  }
}
