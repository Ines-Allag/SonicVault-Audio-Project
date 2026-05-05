import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sonic_vault/shared/models/user_model.dart';

class FirebaseRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  DatabaseReference get _usersRef => _db.ref('users');

  // ====================== AUTH ======================
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? gender,
  }) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final UserModel user = UserModel(
      uid: credential.user!.uid,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      email: email,
      gender: gender,
    );

    // Save user data in Realtime Database
    await _usersRef.child(credential.user!.uid).set(user.toMap());

    return user;
  }

  // ====================== LOGIN ======================
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return await getCurrentUserData() ??
        UserModel(uid: '', firstName: '', lastName: '', birthDate: DateTime.now(), email: email);
  }

  // ====================== RESET PASSWORD ======================
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ====================== LOGOUT ======================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ====================== GET USER DATA ======================
  Future<UserModel?> getCurrentUserData() async {
    if (!isLoggedIn) return null;

    final snapshot = await _usersRef.child(currentUser!.uid).get();

    if (!snapshot.exists || snapshot.value == null) return null;

    // Safe cast
    final data = snapshot.value as Map<dynamic, dynamic>;
    return UserModel.fromMap(data);
  }

  // ====================== UPDATE USER INFO ======================
  Future<void> updateUserInfo({
    required String firstName,
    required String lastName,
  }) async {
    await _usersRef.child(currentUser!.uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }
}