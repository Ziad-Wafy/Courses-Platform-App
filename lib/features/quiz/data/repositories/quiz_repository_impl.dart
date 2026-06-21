import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/quiz_model.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  final FirebaseFirestore firebaseFirestore;

  QuizRepositoryImpl({required this.firebaseFirestore});

  static const String _quizzesCollection = 'quizzes';
  static const String _resultsCollection = 'quiz_results';

  @override
  Future<List<Quiz>> getQuizzesByCourse(String courseId) async {
    try {
      final snapshot = await firebaseFirestore
          .collection(_quizzesCollection)
          .where('courseId', isEqualTo: courseId)
          .get();

      return snapshot.docs
          .map((doc) => _modelToEntity(
              QuizModel.fromJson({...doc.data(), 'id': doc.id})))
          .toList();
    } catch (e) {
      throw Exception('Failed to get quizzes: $e');
    }
  }

  @override
  Future<Quiz> getQuizById(String quizId) async {
    try {
      final doc =
          await firebaseFirestore.collection(_quizzesCollection).doc(quizId).get();

      if (!doc.exists) {
        throw Exception('Quiz not found');
      }

      return _modelToEntity(
          QuizModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}));
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  @override
  Future<String> createQuiz(Quiz quiz) async {
    try {
      final model = _entityToModel(quiz);
      final docRef =
          await firebaseFirestore.collection(_quizzesCollection).add(model.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  @override
  Future<void> submitQuizAnswers(
      String quizId, String studentId, List<StudentAnswer> answers, int timeSpentSeconds) async {
    try {
      final quiz = await getQuizById(quizId);

      int correctCount = 0;
      final studentAnswerModels = <StudentAnswerModel>[];

      for (final answer in answers) {
        final question =
            quiz.questions.firstWhere((q) => q.id == answer.questionId);
        final isCorrect = answer.selectedAnswerId == question.correctAnswerId;

        if (isCorrect) {
          correctCount++;
        }

        studentAnswerModels.add(
          StudentAnswerModel(
            questionId: answer.questionId,
            selectedAnswerId: answer.selectedAnswerId,
            isCorrect: isCorrect,
          ),
        );
      }

      final scorePercentage =
          (correctCount / quiz.totalQuestions * 100).roundToDouble();
      final result = QuizResultModel(
        id: '',
        quizId: quizId,
        studentId: studentId,
        correctAnswers: correctCount,
        totalQuestions: quiz.totalQuestions,
        scorePercentage: scorePercentage,
        completedAt: DateTime.now(),
        timeSpentSeconds: timeSpentSeconds,
        answers: studentAnswerModels,
        passed: scorePercentage >= 60,
      );

      final resultData = result.toJson();
      final docRef = firebaseFirestore.collection(_resultsCollection).doc();

      await docRef.set({
        ...resultData,
        'id': docRef.id,
      });
    } catch (e) {
      throw Exception('Failed to submit answers: $e');
    }
  }

  @override
  Future<QuizResult> getQuizResult(String resultId) async {
    try {
      final doc = await firebaseFirestore
          .collection(_resultsCollection)
          .doc(resultId)
          .get();

      if (!doc.exists) {
        throw Exception('Result not found');
      }

      final model =
          QuizResultModel.fromJson({...doc.data() as Map<String, dynamic>});
      return _resultModelToEntity(model);
    } catch (e) {
      throw Exception('Failed to get result: $e');
    }
  }

  @override
  Future<List<QuizResult>> getStudentQuizResults(String studentId) async {
    try {
      final snapshot = await firebaseFirestore
          .collection(_resultsCollection)
          .where('studentId', isEqualTo: studentId)
          .get();

      return snapshot.docs
          .map((doc) => _resultModelToEntity(
              QuizResultModel.fromJson({...doc.data() as Map<String, dynamic>})))
          .toList();
    } catch (e) {
      throw Exception('Failed to get results: $e');
    }
  }

  @override
  Future<void> updateQuiz(Quiz quiz) async {
    try {
      final model = _entityToModel(quiz);
      await firebaseFirestore
          .collection(_quizzesCollection)
          .doc(quiz.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    try {
      await firebaseFirestore.collection(_quizzesCollection).doc(quizId).delete();
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  // Helper methods to convert between model and entity
  Quiz _modelToEntity(QuizModel model) {
    return Quiz(
      id: model.id,
      title: model.title,
      courseId: model.courseId,
      instructorId: model.instructorId,
      timeLimitMinutes: model.timeLimitMinutes,
      questions: model.questions
          .map((q) => Question(
                id: q.id,
                text: q.text,
                options: q.options
                    .map((o) => Answer(id: o.id, text: o.text))
                    .toList(),
                correctAnswerId: q.correctAnswerId,
                points: q.points,
              ))
          .toList(),
      createdAt: model.createdAt,
      isLocked: model.isLocked,
    );
  }

  QuizModel _entityToModel(Quiz entity) {
    return QuizModel(
      id: entity.id,
      title: entity.title,
      courseId: entity.courseId,
      instructorId: entity.instructorId,
      timeLimitMinutes: entity.timeLimitMinutes,
      totalQuestions: entity.totalQuestions,
      questions: entity.questions
          .map((q) => QuestionModel(
                id: q.id,
                text: q.text,
                options: q.options
                    .map((o) => AnswerModel(id: o.id, text: o.text))
                    .toList(),
                correctAnswerId: q.correctAnswerId,
                points: q.points,
              ))
          .toList(),
      createdAt: entity.createdAt,
      isLocked: entity.isLocked,
    );
  }

  QuizResult _resultModelToEntity(QuizResultModel model) {
    return QuizResult(
      id: model.id,
      quizId: model.quizId,
      studentId: model.studentId,
      correctAnswers: model.correctAnswers,
      totalQuestions: model.totalQuestions,
      scorePercentage: model.scorePercentage,
      completedAt: model.completedAt,
      timeSpentSeconds: model.timeSpentSeconds,
      answers: model.answers
          .map((a) => StudentAnswer(
                questionId: a.questionId,
                selectedAnswerId: a.selectedAnswerId,
                isCorrect: a.isCorrect,
              ))
          .toList(),
    );
  }
}

extension on double {
  double roundToDouble() {
    return (this * 100).round() / 100;
  }
}
