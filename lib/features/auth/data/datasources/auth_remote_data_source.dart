import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> login(String email, String password);
  Future<UserCredential> signUp(
      String email, String password, String fullName, String role);
  Future<void> resetPassword(String email);
  Future<UserCredential> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<UserCredential> login(String email, String password) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signUp(
      String email, String password, String fullName, String role) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user?.updateDisplayName(fullName);
    // TODO: حفظ الـ role في Firestore في الخطوة الجاية
    return userCredential;
  }

  @override
  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("Google Sign-In canceled by user");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final accessToken = googleAuth.accessToken;
    if (accessToken == null) {
      throw Exception("Failed to get Google access token");
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: googleAuth.idToken,
    );

    return await firebaseAuth.signInWithCredential(credential);
  }
}