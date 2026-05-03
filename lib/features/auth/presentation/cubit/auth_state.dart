import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthResetPasswordSuccess extends AuthState {}

class AuthSuccess extends AuthState {
  final UserCredential userCredential;
  AuthSuccess({required this.userCredential});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class PasswordResetEmailSent extends AuthState {}