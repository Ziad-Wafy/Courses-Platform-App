class Quiz {
  final String id;
  final String title;
  final String courseId;
  final String instructorId;
  final int timeLimitMinutes;
  final List<Question> questions;
  final DateTime createdAt;
  final bool isLocked;

  Quiz({
    required this.id,
    required this.title,
    required this.courseId,
    required this.instructorId,
    required this.timeLimitMinutes,
    required this.questions,
    required this.createdAt,
    this.isLocked = false,
  });

  int get totalQuestions => questions.length;
}

class Question {
  final String id;
  final String text;
  final List<Answer> options;
  final String correctAnswerId;
  final int points;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerId,
    this.points = 1,
  });
}

class Answer {
  final String id;
  final String text;

  Answer({
    required this.id,
    required this.text,
  });
}

class QuizResult {
  final String id;
  final String quizId;
  final String studentId;
  final int correctAnswers;
  final int totalQuestions;
  final double scorePercentage;
  final DateTime completedAt;
  final int timeSpentSeconds;
  final List<StudentAnswer> answers;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.completedAt,
    required this.timeSpentSeconds,
    required this.answers,
  });

  bool get passed => scorePercentage >= 60;
}

class StudentAnswer {
  final String questionId;
  final String selectedAnswerId;
  final bool isCorrect;

  StudentAnswer({
    required this.questionId,
    required this.selectedAnswerId,
    required this.isCorrect,
  });
}
