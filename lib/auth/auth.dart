import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  GoogleSignIn get _googleSignIn => GoogleSignIn();
  GoogleSignInAccount? gUser;
  signInWithGoogle() async {
    gUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);
    gid = gUser!.id;
    gEmail = gUser!.email;

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}
