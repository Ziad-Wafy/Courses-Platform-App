import 'package:flutter/material.dart';

import '../../presentation/ui/screens/create_quiz_screen.dart';
import '../../presentation/ui/screens/quiz_completion_screen.dart';
import '../../presentation/ui/screens/quiz_question_screen.dart';
import '../../presentation/ui/screens/quizzes_assessments_screen.dart';

class QuizRoutes {
  static const String quizList = '/quiz/list';
  static const String quizQuestion = '/quiz/question';
  static const String quizCompletion = '/quiz/completion';
  static const String createQuiz = '/quiz/create';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      quizList: (context) {
        final courseId = ModalRoute.of(context)!.settings.arguments as String;
        return QuizzesAndAssessmentsScreen(courseId: courseId);
      },
      quizQuestion: (context) {
        final quizId = ModalRoute.of(context)!.settings.arguments as String;
        return QuizQuestionScreen(quizId: quizId);
      },
      quizCompletion: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return QuizCompletionScreen(
          correctAnswers: args['correctAnswers'] as int,
          totalQuestions: args['totalQuestions'] as int,
          scorePercentage: args['scorePercentage'] as double,
          quizId: args['quizId'] as String,
          courseid: args['courseId'] as String,
        );
      },
      createQuiz: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return CreateQuizScreen(
          courseId: args['courseId'] as String,
          instructorId: args['instructorId'] as String,
        );
      },
    };
  }
}
