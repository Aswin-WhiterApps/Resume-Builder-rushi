import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class Auth {
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  static String? gid;
  static String? gEmail;

  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createNewUserWithEmail(
      {required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        "630791257688-bb1fkmr9t6nf2k4ddbv7e2dpbq0aprf9.apps.googleusercontent.com",
  );
  GoogleSignInAccount? _gUser;
  signInWithGoogle() async {
    _gUser = await _googleSignIn.signIn();
    if (_gUser == null) {
      debugPrint('Google Sign-In cancelled or failed');
      return null;
    }

    final GoogleSignInAuthentication gAuth = await _gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);
    gid = _gUser!.id;
    gEmail = _gUser!.email;

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}
