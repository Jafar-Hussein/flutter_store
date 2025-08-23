class User {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final List<String> savedProductIds;
  final List<String> lastViewedProductIds;
  final UserRole role;

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
    required this.role,
  });

//get user role
void _getUserRoleFromId(String uid) async {
  final userDoc = await _firestore.collection(userCollection).doc(uid).get();
  if (!userDoc.exists) {
    throw Exception('Användardokument finns inte');
  }
  try {
    final data = userDoc.data()!;
    final roleString = data['role'] as String?;
    if (roleString == null) {
      throw Exception('Användarroll saknas i dokumentet');
    }
    return UserRole.values.firstWhere(
      (e) => e.toString() == 'UserRole.$roleString',
      orElse: () => UserRole.customer,
    );
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

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
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.customer,
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
      'role': role.toString().split('.').last,
    };
  }
}

enum UserRole {
  customer,
  admin,
}
