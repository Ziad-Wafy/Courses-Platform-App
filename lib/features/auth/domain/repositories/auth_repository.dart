import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserCredential> login(String email, String password);
  Future<UserCredential> signUp(
    String email,
    String password,
    String fullName,
    String role,
  );
  Future<void> resetPassword(String email);
  Future<UserCredential> signInWithGoogle();
  Future<UserModel?> getUserData(String uid);
}
