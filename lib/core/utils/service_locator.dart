import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/quiz/data/repositories/quiz_repository_impl.dart';
import '../../features/quiz/domain/repositories/quiz_repository.dart';
import '../../features/quiz/domain/usecases/quiz_usecases.dart';
import '../../features/quiz/presentation/cubit/quiz_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 1. External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn(scopes: ['email']));
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // 2. Auth - Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );

  // 3. Auth - Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // 4. Auth - Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));

  // 5. Auth - Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      resetPasswordUseCase: sl(),
      signInWithGoogleUseCase: sl(),
    ),
  );

  // 6. Quiz - Repositories
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(firebaseFirestore: sl()),
  );

  // 7. Quiz - Use Cases
  sl.registerLazySingleton(() => GetQuizzesUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateQuizUseCase(sl()));
  sl.registerLazySingleton(() => SubmitQuizAnswersUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizResultUseCase(sl()));
  sl.registerLazySingleton(() => GetStudentQuizResultsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuizUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuizUseCase(sl()));

  // 8. Quiz - Cubit
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