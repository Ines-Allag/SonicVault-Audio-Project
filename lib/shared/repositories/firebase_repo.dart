import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sonic_vault/shared/models/user_model.dart';

class FirebaseRepository {
  // The two Firebase services we use
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────────
  // CHECK: is the user already logged in?
  // ─────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  // ─────────────────────────────────────────
  // REGISTER: create account + save to Firestore
  // ─────────────────────────────────────────
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? gender,
  }) async {
    // Step 1 — create the account in Firebase Auth
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Step 2 — build our UserModel
    final UserModel user = UserModel(
      uid: credential.user!.uid,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      email: email,
      gender: gender,
    );

    // Step 3 — save the extra info to Firestore
    // Firebase Auth only stores email + password
    // Everything else (name, birthdate) goes in Firestore
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toMap());

    return user;
  }

  // ─────────────────────────────────────────
  // LOGIN: sign in with email + password
  // ─────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Step 1 — sign in with Firebase Auth
    final UserCredential credential = await _auth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Step 2 — fetch the user's extra info from Firestore
    final DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ─────────────────────────────────────────
  // RESET PASSWORD: send reset email
  // ─────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────
  // GET current user data from Firestore
  // ─────────────────────────────────────────
  Future<UserModel?> getCurrentUserData() async {
    if (!isLoggedIn) return null;

    final DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}