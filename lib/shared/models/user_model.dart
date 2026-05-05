class UserModel {
  final String uid;          // Firebase gives this automatically
  final String firstName;    // required
  final String lastName;     // required
  final DateTime birthDate;  // required — for age validation
  final String email;        // required
  final String? gender;      // optional

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    this.gender,
  });

  // Converts UserModel → Map so we can save it to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'email': email,
      'gender': gender,
    };
  }

  // Converts Map → UserModel so we can read it back
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'] as String)
          : DateTime.now(),
      email: map['email'] as String? ?? '',
      gender: map['gender'] as String?,
    );
  }
  // Full name helper — used in the stats welcome message
  String get fullName => '$firstName $lastName';
}