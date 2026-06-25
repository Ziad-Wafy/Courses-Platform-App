import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.resetPasswordUseCase,
    required this.signInWithGoogleUseCase,
  }) : super(AuthInitial());

  String _handleFirebaseError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return e.message ?? 'An unexpected error occurred.';
      }
    }
    return e.toString();
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.call(email, password);
      emit(AuthSuccess(userCredential: user));
    } catch (e) {
      emit(AuthError(message: _handleFirebaseError(e)));
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signUpUseCase.call(email, password, fullName, role);
      emit(AuthSuccess(userCredential: user));
    } catch (e) {
      emit(AuthError(message: _handleFirebaseError(e)));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogleUseCase.call();
      emit(AuthSuccess(userCredential: user));
    } catch (e) {
      emit(AuthError(message: _handleFirebaseError(e)));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await resetPasswordUseCase.call(email);
      emit(PasswordResetEmailSent());
    } catch (e) {
      emit(AuthError(message: _handleFirebaseError(e)));
    }
  }
}
