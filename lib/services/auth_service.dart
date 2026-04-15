import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with Email and Password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? emergencyName,
    String? emergencyPhone,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'emergencyName': emergencyName ?? '',
          'emergencyPhone': emergencyPhone ?? '',
          'role': 'victim',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Login with Email and Password
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Get User Data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  // Get user role
  Future<String> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['role'] ?? 'victim';
    }
    return 'victim';
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
