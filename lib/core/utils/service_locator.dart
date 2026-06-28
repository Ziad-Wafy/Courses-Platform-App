import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learning_management_system/features/chat/data/data_source/chat_data_source.dart';
import 'package:learning_management_system/features/chat/data/data_source/chat_data_source_impl.dart';
import 'package:learning_management_system/features/chat/data/repositories/chat_repo_impl.dart';
import 'package:learning_management_system/features/chat/domain/repositories/chat_repo.dart';
import 'package:learning_management_system/features/chat/presentation/state_management/cubit/chat_cubit.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // =========================
  // External
  // =========================

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn(scopes: ['email']));

  // =========================
  // Auth - Data Source
  // =========================

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  // =========================
  // Auth - Repository
  // =========================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // =========================
  // Auth - UseCases
  // =========================

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));

  // =========================
  // Auth Cubit
  // =========================

  sl.registerLazySingleton(
    () => AuthCubit(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      resetPasswordUseCase: sl(),
      signInWithGoogleUseCase: sl(),
    ),
  );

  // =========================
  // Profile Cubit
  // =========================

  sl.registerFactory(
    () => ProfileCubit(
      firestore: sl(),
      firebaseAuth: sl(),
      storage: sl(),
    ),
  );


  // =========================
  // Chat - Data Source
  // =========================

  sl.registerLazySingleton<ChatDataSource>(
    () => ChatDataSourceImpl(sl()),
  );

  // =========================
  // Chat - Repository
  // =========================

  sl.registerLazySingleton<ChatRepo>(
    () => ChatRepoImpl(chatDataSource: sl()),
  );

  // =========================
  // Chat Cubit
  // =========================

  sl.registerLazySingleton(
    () => ChatCubit(chatRepo: sl()),
  );
}
