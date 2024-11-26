// lib/models/destination.dart
import 'coordinate.dart';

class Destination {
  final String id;
  final String name;
  final Coordinate coordinates;
  final String description;
  final double distanceFromTalca;

  Destination({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.description,
    required this.distanceFromTalca,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      coordinates: Coordinate.fromJson(json['coordinates']),
      description: json['description'],
      distanceFromTalca: json['distanceFromTalca'].toDouble(),
    );
  }
}
