import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
