class User {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final List<String> savedProductIds;

  User({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.savedProductIds,
  });

  factory User.fromJson(Map<String, dynamic> json, String uid) {
    return User(
      uid: uid,
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      savedProductIds: List<String>.from(json['savedProducts'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'savedProducts': savedProductIds,
    };
  }
}
