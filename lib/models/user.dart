class User {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final List<String> savedProductIds;
  final List<String> lastViewedProductIds;

  final String stripeCustomerId;

  User({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.savedProductIds,
    required this.stripeCustomerId,
    required this.lastViewedProductIds,
  });

  factory User.fromJson(Map<String, dynamic> json, String uid) {
    return User(
      uid: uid,
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      savedProductIds: List<String>.from(json['savedProducts'] ?? []),
      stripeCustomerId: json['stripeCustomerId'] ?? '',
      lastViewedProductIds: List<String>.from(
        json['lastViewedProductIds'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'savedProducts': savedProductIds,
      'stripeCustomerId': stripeCustomerId,
      'lastViewedProductIds': lastViewedProductIds,
    };
  }
}
