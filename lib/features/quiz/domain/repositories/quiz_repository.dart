import '../entities/quiz_entity.dart';

abstract class QuizRepository {
  Future<List<Quiz>> getQuizzesByCourse(String courseId);
  Future<Quiz> getQuizById(String quizId);
  Future<String> createQuiz(Quiz quiz);
  Future<void> submitQuizAnswers(String quizId, String studentId, List<StudentAnswer> answers, int timeSpentSeconds);
  Future<QuizResult> getQuizResult(String resultId);
  Future<List<QuizResult>> getStudentQuizResults(String studentId);
  Future<void> updateQuiz(Quiz quiz);
  Future<void> deleteQuiz(String quizId);
}
