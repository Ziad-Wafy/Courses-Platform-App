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

import 'package:learning_management_system/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:learning_management_system/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:learning_management_system/features/auth/domain/repositories/auth_repository.dart';
import 'package:learning_management_system/features/auth/domain/usecases/auth_usecases.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:learning_management_system/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';
import 'package:learning_management_system/features/auth/data/models/user_model.dart';

import 'package:learning_management_system/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:learning_management_system/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:learning_management_system/features/quiz/domain/usecases/quiz_usecases.dart';
import 'package:learning_management_system/features/quiz/presentation/cubit/quiz_cubit.dart';

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
      authRepository: sl(),
    ),
  );

  // =========================
  // Profile Cubit
  // =========================

  sl.registerLazySingleton(
    () => ProfileCubit(firestore: sl(), firebaseAuth: sl(), storage: sl()),
  );

  // =========================
  // Chat - Data Source
  // =========================

  sl.registerLazySingleton<ChatDataSource>(() => ChatDataSourceImpl(sl()));

  // =========================
  // Chat - Repository
  // =========================

  sl.registerLazySingleton<ChatRepo>(() => ChatRepoImpl(chatDataSource: sl()));

  // =========================
  // Chat Cubit
  // =========================

  sl.registerLazySingleton(() => ChatCubit(chatRepo: sl()));

  // =========================
  // Home Cubit (LazySingleton - will be updated with user data)
  // =========================

  sl.registerLazySingleton(
    () => HomeCubit(firestore: sl(), currentUser: UserModel.empty()),
  );

  // =========================
  // Quiz Repository
  // =========================

  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(firebaseFirestore: sl()),
  );

  // =========================
  // Quiz UseCases
  // =========================

  sl.registerLazySingleton(() => GetQuizzesUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateQuizUseCase(sl()));
  sl.registerLazySingleton(() => SubmitQuizAnswersUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizResultUseCase(sl()));
  sl.registerLazySingleton(() => GetStudentQuizResultsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuizUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuizUseCase(sl()));

  // =========================
  // Quiz Cubit
  // =========================

  sl.registerFactory(
    () => QuizCubit(
      getQuizzesUseCase: sl(),
      getQuizByIdUseCase: sl(),
      createQuizUseCase: sl(),
      submitQuizAnswersUseCase: sl(),
      getQuizResultUseCase: sl(),
      getStudentQuizResultsUseCase: sl(),
      updateQuizUseCase: sl(),
      deleteQuizUseCase: sl(),
    ),
  );
}
