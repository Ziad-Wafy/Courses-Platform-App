import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/quiz_entity.dart';
import '../../domain/usecases/quiz_usecases.dart';

// States
abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizzesLoaded extends QuizState {
  final List<Quiz> quizzes;
  final List<QuizResult> studentResults;
  final double averageScore;

  const QuizzesLoaded({
    required this.quizzes,
    this.studentResults = const [],
    this.averageScore = 0.0,
  });

  @override
  List<Object?> get props => [quizzes, studentResults, averageScore];

  QuizzesLoaded copyWith({
    List<Quiz>? quizzes,
    List<QuizResult>? studentResults,
    double? averageScore,
  }) {
    return QuizzesLoaded(
      quizzes: quizzes ?? this.quizzes,
      studentResults: studentResults ?? this.studentResults,
      averageScore: averageScore ?? this.averageScore,
    );
  }
}

class QuizLoaded extends QuizState {
  final Quiz quiz;
  const QuizLoaded(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizCreated extends QuizState {
  final String quizId;
  const QuizCreated(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class QuizAnswersSubmitted extends QuizState {
  final QuizResult result;
  const QuizAnswersSubmitted(this.result);

  @override
  List<Object?> get props => [result];
}

class QuizResultLoaded extends QuizState {
  final QuizResult result;
  const QuizResultLoaded(this.result);

  @override
  List<Object?> get props => [result];
}

class QuizError extends QuizState {
  final String message;
  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class QuizCubit extends Cubit<QuizState> {
  final GetQuizzesUseCase getQuizzesUseCase;
  final GetQuizByIdUseCase getQuizByIdUseCase;
  final CreateQuizUseCase createQuizUseCase;
  final SubmitQuizAnswersUseCase submitQuizAnswersUseCase;
  final GetQuizResultUseCase getQuizResultUseCase;
  final GetStudentQuizResultsUseCase getStudentQuizResultsUseCase;
  final UpdateQuizUseCase updateQuizUseCase;
  final DeleteQuizUseCase deleteQuizUseCase;

  QuizCubit({
    required this.getQuizzesUseCase,
    required this.getQuizByIdUseCase,
    required this.createQuizUseCase,
    required this.submitQuizAnswersUseCase,
    required this.getQuizResultUseCase,
    required this.getStudentQuizResultsUseCase,
    required this.updateQuizUseCase,
    required this.deleteQuizUseCase,
  }) : super(const QuizInitial());

  Future<void> getQuizzesByCourse(String courseId) async {
    emit(const QuizLoading());
    try {
      final quizzes = await getQuizzesUseCase(courseId);
      emit(QuizzesLoaded(quizzes: quizzes));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> getQuizById(String quizId) async {
    emit(const QuizLoading());
    try {
      final quiz = await getQuizByIdUseCase(quizId);
      emit(QuizLoaded(quiz));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> createQuiz(Quiz quiz) async {
    emit(const QuizLoading());
    try {
      final quizId = await createQuizUseCase(quiz);
      emit(QuizCreated(quizId));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> submitAnswers(
    String quizId,
    String studentId,
    List<StudentAnswer> answers,
    int timeSpentSeconds,
  ) async {
    emit(const QuizLoading());
    try {
      await submitQuizAnswersUseCase(quizId, studentId, answers, timeSpentSeconds);
      final results = await getStudentQuizResultsUseCase(studentId);
      if (results.isNotEmpty) {
        results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        final latestResult = results.first;
        emit(QuizAnswersSubmitted(latestResult));
      }
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> getQuizResult(String resultId) async {
    emit(const QuizLoading());
    try {
      final result = await getQuizResultUseCase(resultId);
      emit(QuizResultLoaded(result));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> getStudentResults(String studentId) async {
    final currentState = state;
    try {
      final results = await getStudentQuizResultsUseCase(studentId);
      double averageScore = 0;
      if (results.isNotEmpty) {
        averageScore = results
                .fold(0.0, (sum, result) => sum + result.scorePercentage) /
            results.length;
      }

      if (currentState is QuizzesLoaded) {
        emit(currentState.copyWith(
          studentResults: results,
          averageScore: averageScore,
        ));
      } else {
        emit(QuizzesLoaded(
          quizzes: const [],
          studentResults: results,
          averageScore: averageScore,
        ));
      }
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> updateQuiz(Quiz quiz) async {
    try {
      await updateQuizUseCase(quiz);
      await getQuizById(quiz.id);
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      await deleteQuizUseCase(quizId);
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }
}
