import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/service_locator.dart';
import '../../cubit/quiz_cubit.dart';
import '../widgets/common_widgets.dart';

class QuizzesAndAssessmentsScreen extends StatefulWidget {
  final String courseId;

  const QuizzesAndAssessmentsScreen({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<QuizzesAndAssessmentsScreen> createState() =>
      _QuizzesAndAssessmentsScreenState();
}

class _QuizzesAndAssessmentsScreenState
    extends State<QuizzesAndAssessmentsScreen> {
  late QuizCubit quizCubit;

  @override
  void initState() {
    super.initState();
    quizCubit = sl<QuizCubit>();
    quizCubit.getQuizzesByCourse(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocProvider.value(
        value: quizCubit,
        child: BlocListener<QuizCubit, QuizState>(
          listener: (context, state) {
            if (state is QuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Column(
            children: [
              QuizHeader(
                title: 'Quizzes & Assessments',
                onBackPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: BlocBuilder<QuizCubit, QuizState>(
                  builder: (context, state) {
                    if (state is QuizLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF4A90E2),
                          ),
                        ),
                      );
                    }

                    if (state is QuizzesLoaded) {
                      if (state.quizzes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz,
                                size: 64.sp,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No quizzes available',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Calculate average score
                      double averageScore = 0;
                      final quizzesWithScores = state.quizzes
                          .where((quiz) => false) // Filter completed quizzes
                          .toList();

                      if (quizzesWithScores.isNotEmpty) {
                        // This is a placeholder - you'd get actual scores from quiz results
                        averageScore = 87.5;
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            if (averageScore > 0)
                              AverageScoreCard(averageScore: averageScore),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.quizzes.length,
                              itemBuilder: (context, index) {
                                final quiz = state.quizzes[index];
                                return QuizCard(
                                  title: quiz.title,
                                  questionsCount: quiz.totalQuestions,
                                  timeLimit: quiz.timeLimitMinutes,
                                  isLocked: quiz.isLocked,
                                  onStartQuiz: !quiz.isLocked
                                      ? () {
                                          Navigator.pushNamed(
                                            context,
                                            '/quiz/question',
                                            arguments: quiz.id,
                                          );
                                        }
                                      : null,
                                );
                              },
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      );
                    }

                    if (state is QuizError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64.sp,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Error loading quizzes',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () {
                                quizCubit.getQuizzesByCourse(widget.courseId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
