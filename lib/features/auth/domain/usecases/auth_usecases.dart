import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserCredential> call(String email, String password) {
    return repository.login(email, password);
  }
}

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<UserCredential> call(
      String email, String password, String fullName, String role) {
    return repository.signUp(email, password, fullName, role);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<void> call(String email) {
    return repository.resetPassword(email);
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<UserCredential> call() {
    return repository.signInWithGoogle();
  }
}