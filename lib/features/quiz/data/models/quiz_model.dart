class QuizModel {
  final String id;
  final String title;
  final String courseId;
  final String instructorId;
  final int timeLimitMinutes;
  final int totalQuestions;
  final List<QuestionModel> questions;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isLocked;

  QuizModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.instructorId,
    required this.timeLimitMinutes,
    required this.totalQuestions,
    required this.questions,
    required this.createdAt,
    this.updatedAt,
    this.isLocked = false,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      courseId: json['courseId'] as String,
      instructorId: json['instructorId'] as String,
      timeLimitMinutes: json['timeLimitMinutes'] as int,
      totalQuestions: json['totalQuestions'] as int,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'courseId': courseId,
      'instructorId': instructorId,
      'timeLimitMinutes': timeLimitMinutes,
      'totalQuestions': totalQuestions,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isLocked': isLocked,
    };
  }

  QuizModel copyWith({
    String? id,
    String? title,
    String? courseId,
    String? instructorId,
    int? timeLimitMinutes,
    int? totalQuestions,
    List<QuestionModel>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLocked,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      instructorId: instructorId ?? this.instructorId,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class QuestionModel {
  final String id;
  final String text;
  final List<AnswerModel> options;
  final String correctAnswerId;
  final int points;

  QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerId,
    this.points = 1,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => AnswerModel.fromJson(o as Map<String, dynamic>))
          .toList(),
      correctAnswerId: json['correctAnswerId'] as String,
      points: json['points'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options.map((o) => o.toJson()).toList(),
      'correctAnswerId': correctAnswerId,
      'points': points,
    };
  }

  QuestionModel copyWith({
    String? id,
    String? text,
    List<AnswerModel>? options,
    String? correctAnswerId,
    int? points,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctAnswerId: correctAnswerId ?? this.correctAnswerId,
      points: points ?? this.points,
    );
  }
}

class AnswerModel {
  final String id;
  final String text;

  AnswerModel({
    required this.id,
    required this.text,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }

  AnswerModel copyWith({
    String? id,
    String? text,
  }) {
    return AnswerModel(
      id: id ?? this.id,
      text: text ?? this.text,
    );
  }
}

class QuizResultModel {
  final String id;
  final String quizId;
  final String studentId;
  final int correctAnswers;
  final int totalQuestions;
  final double scorePercentage;
  final DateTime completedAt;
  final int timeSpentSeconds;
  final List<StudentAnswerModel> answers;
  final bool passed;

  QuizResultModel({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.completedAt,
    required this.timeSpentSeconds,
    required this.answers,
    required this.passed,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      studentId: json['studentId'] as String,
      correctAnswers: json['correctAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      scorePercentage: (json['scorePercentage'] as num).toDouble(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      timeSpentSeconds: json['timeSpentSeconds'] as int,
      answers: (json['answers'] as List<dynamic>)
          .map((a) => StudentAnswerModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      passed: json['passed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'studentId': studentId,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'scorePercentage': scorePercentage,
      'completedAt': completedAt.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
      'answers': answers.map((a) => a.toJson()).toList(),
      'passed': passed,
    };
  }
}

class StudentAnswerModel {
  final String questionId;
  final String selectedAnswerId;
  final bool isCorrect;

  StudentAnswerModel({
    required this.questionId,
    required this.selectedAnswerId,
    required this.isCorrect,
  });

  factory StudentAnswerModel.fromJson(Map<String, dynamic> json) {
    return StudentAnswerModel(
      questionId: json['questionId'] as String,
      selectedAnswerId: json['selectedAnswerId'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswerId': selectedAnswerId,
      'isCorrect': isCorrect,
    };
  }
}
