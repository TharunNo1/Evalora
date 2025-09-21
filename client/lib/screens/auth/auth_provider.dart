import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Declare a global instance to avoid constructor issues
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: '903097631031-hvb07do8lagc16eqjccd8ca1ov68tc9m.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

// Provide FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// AuthNotifier using ChangeNotifier instead of StateNotifier
class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth;
  User? currentUser;

  AuthNotifier(this._auth) {
    _auth.authStateChanges().listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    final userCredential =
        await _auth.signInWithEmailAndPassword(email: email, password: password);
    currentUser = userCredential.user;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    // Use the global instance instead of calling constructor again
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return; // canceled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    currentUser = userCredential.user;
    notifyListeners();
  }

  Future<void> signOut() async {
  await googleSignIn.disconnect();  // Clear Google session & revoke permissions
  await googleSignIn.signOut();     // Sign out GoogleSignIn
  await _auth.signOut();              // Sign out Firebase Auth

  currentUser = null;
  notifyListeners();
}

}

// Provide AuthNotifier
final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  return AuthNotifier(auth);
});
