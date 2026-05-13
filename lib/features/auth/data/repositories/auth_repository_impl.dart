import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserCredential> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<UserCredential> signUp(
      String email, String password, String fullName, String role) async {
    return await remoteDataSource.signUp(email, password, fullName, role);
  }

  @override
  Future<void> resetPassword(String email) async {
    return await remoteDataSource.resetPassword(email);
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }
}