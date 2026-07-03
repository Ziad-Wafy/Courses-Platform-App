import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// ✅ حالة نجاح تسجيل الدخول - تحمل كائن الـ User وليس الـ Credential بالكامل
class AuthSuccess extends AuthState {
  final User? user;
  final UserModel? userData;
  AuthSuccess({this.user, this.userData});
}

// ✅ حالة نجاح إنشاء الحساب
class AuthSignUpSuccess extends AuthState {
  final User? user;
  final UserModel? userData;
  AuthSignUpSuccess({this.user, this.userData});
}

// ✅ حالة نجاح إرسال رابط إعادة تعيين كلمة المرور (تم دمج الحالتين)
class PasswordResetEmailSent extends AuthState {}

// ✅ حالة تسجيل الخروج بنجاح
class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
