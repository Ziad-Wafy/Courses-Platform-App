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
  const QuizzesLoaded(this.quizzes);

  @override
  List<Object?> get props => [quizzes];
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

class StudentQuizResultsLoaded extends QuizState {
  final List<QuizResult> results;
  final double averageScore;
  const StudentQuizResultsLoaded(this.results, this.averageScore);

  @override
  List<Object?> get props => [results, averageScore];
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
      emit(QuizzesLoaded(quizzes));
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
  ) async {
    emit(const QuizLoading());
    try {
      await submitQuizAnswersUseCase(quizId, studentId, answers);
      // Get the results after submission
      final results = await getStudentQuizResultsUseCase(studentId);
      if (results.isNotEmpty) {
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
    emit(const QuizLoading());
    try {
      final results = await getStudentQuizResultsUseCase(studentId);
      double averageScore = 0;
      if (results.isNotEmpty) {
        averageScore = results
                .fold(0.0, (sum, result) => sum + result.scorePercentage) /
            results.length;
      }
      emit(StudentQuizResultsLoaded(results, averageScore));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> updateQuiz(Quiz quiz) async {
    try {
      await updateQuizUseCase(quiz);
      // Refresh the quiz data
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
