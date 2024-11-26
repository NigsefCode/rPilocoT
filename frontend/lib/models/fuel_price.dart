// lib/models/fuel_price.dart
class FuelPrice {
  final String id;
  final String fuelType;
  final double price;
  final DateTime updatedAt;

  FuelPrice({
    required this.id,
    required this.fuelType,
    required this.price,
    required this.updatedAt,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    return FuelPrice(
      id: json['_id'],
      fuelType: json['fuelType'],
      price: json['price'].toDouble(),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
