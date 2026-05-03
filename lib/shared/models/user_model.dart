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

  // Converts Firestore Map → UserModel so we can read it back
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      birthDate: DateTime.parse(map['birthDate']),
      email: map['email'],
      gender: map['gender'],
    );
  }

  // Full name helper — used in the stats welcome message
  String get fullName => '$firstName $lastName';
}