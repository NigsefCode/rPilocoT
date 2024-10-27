class Vehicle {
  String? id;
  String brand;
  String model;
  String year;
  String engineType;
  String engineSize;
  String userId;

  Vehicle({
    this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.engineType,
    required this.engineSize,
    required this.userId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      engineType: json['engineType'],
      engineSize: json['engineSize'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'engineType': engineType,
      'engineSize': engineSize,
      'userId': userId,
    };
  }
}
