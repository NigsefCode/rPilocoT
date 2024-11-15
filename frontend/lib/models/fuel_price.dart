// lib/models/fuel_price.dart
class FuelPrice {
  final String fuelType;
  final double price;
  final DateTime updatedAt;

  FuelPrice({
    required this.fuelType,
    required this.price,
    required this.updatedAt,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    return FuelPrice(
      fuelType: json['fuelType'],
      price: json['price']?.toDouble() ?? 0.0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fuelType': fuelType,
      'price': price,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
