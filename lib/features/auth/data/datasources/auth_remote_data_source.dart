import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
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

    final uid = userCredential.user!.uid;

    // ✅ حفظ displayName في Firebase Auth
    await userCredential.user?.updateDisplayName(fullName);

    // ✅ حفظ بيانات المستخدم في Firestore
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role, // 'Student' أو 'Teacher'
      'createdAt': FieldValue.serverTimestamp(),
    });

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

    final userCredential =
        await firebaseAuth.signInWithCredential(credential);

    // ✅ لو مستخدم جديد بـ Google، احفظ بياناته في Firestore
    if (userCredential.additionalUserInfo?.isNewUser == true) {
      final uid = userCredential.user!.uid;
      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': userCredential.user?.displayName ?? '',
        'email': userCredential.user?.email ?? '',
        'role': 'Student', // Default role for Google Sign-In
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }
}