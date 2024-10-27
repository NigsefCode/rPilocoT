class User {
  String? id;
  String name;
  String email;
  bool hasCompletedQuestionnaire;

  User({
    this.id,
    required this.name,
    required this.email,
    this.hasCompletedQuestionnaire = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      hasCompletedQuestionnaire: json['hasCompletedQuestionnaire'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'hasCompletedQuestionnaire': hasCompletedQuestionnaire,
    };
  }
}
