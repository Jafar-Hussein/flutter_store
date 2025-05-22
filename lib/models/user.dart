class User {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final List<String> savedProductIds; // lista med sparade produkt-ID:n

  User({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.savedProductIds,
  });

  /// Skapar ett User-objekt från en JSON-karta
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      savedProductIds: List<String>.from(json['savedProducts'] ?? []),
    );
  }

  /// Konverterar User-objekt till JSON-karta
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'savedProducts': savedProductIds,
    };
  }
}
