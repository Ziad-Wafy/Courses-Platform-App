import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class GetQuizzesUseCase {
  final QuizRepository repository;

  GetQuizzesUseCase(this.repository);

  Future<List<Quiz>> call(String courseId) async {
    return repository.getQuizzesByCourse(courseId);
  }
}

class GetQuizByIdUseCase {
  final QuizRepository repository;

  GetQuizByIdUseCase(this.repository);

  Future<Quiz> call(String quizId) async {
    return repository.getQuizById(quizId);
  }
}

class CreateQuizUseCase {
  final QuizRepository repository;

  CreateQuizUseCase(this.repository);

  Future<String> call(Quiz quiz) async {
    return repository.createQuiz(quiz);
  }
}

class SubmitQuizAnswersUseCase {
  final QuizRepository repository;

  SubmitQuizAnswersUseCase(this.repository);

  Future<void> call(
    String quizId,
    String studentId,
    List<StudentAnswer> answers,
    int timeSpentSeconds,
  ) async {
    return repository.submitQuizAnswers(quizId, studentId, answers, timeSpentSeconds);
  }
}

class GetQuizResultUseCase {
  final QuizRepository repository;

  GetQuizResultUseCase(this.repository);

  Future<QuizResult> call(String resultId) async {
    return repository.getQuizResult(resultId);
  }
}

class GetStudentQuizResultsUseCase {
  final QuizRepository repository;

  GetStudentQuizResultsUseCase(this.repository);

  Future<List<QuizResult>> call(String studentId) async {
    return repository.getStudentQuizResults(studentId);
  }
}

class UpdateQuizUseCase {
  final QuizRepository repository;

  UpdateQuizUseCase(this.repository);

  Future<void> call(Quiz quiz) async {
    return repository.updateQuiz(quiz);
  }
}

class DeleteQuizUseCase {
  final QuizRepository repository;

  DeleteQuizUseCase(this.repository);

  Future<void> call(String quizId) async {
    return repository.deleteQuiz(quizId);
  }
}
