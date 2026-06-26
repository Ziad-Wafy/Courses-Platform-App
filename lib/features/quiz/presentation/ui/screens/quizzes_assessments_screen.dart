import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_color.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../cubit/quiz_cubit.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../widgets/common_widgets.dart';

class QuizzesAndAssessmentsScreen extends StatefulWidget {
  final String courseId;

  const QuizzesAndAssessmentsScreen({
    super.key,
    required this.courseId,
  });

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
    final studentId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (studentId.isNotEmpty) {
      quizCubit.getStudentResults(studentId);
    }
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
                            AppColors.primary,
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

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            if (state.averageScore > 0)
                              AverageScoreCard(averageScore: state.averageScore),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.quizzes.length,
                              itemBuilder: (context, index) {
                                final quiz = state.quizzes[index];
                                // Find result for this quiz if any
                                final result = state.studentResults
                                    .where((r) => r.quizId == quiz.id)
                                    .toList();

                                QuizResult? latestResult;
                                if (result.isNotEmpty) {
                                  result.sort((a, b) => b.completedAt.compareTo(a.completedAt));
                                  latestResult = result.first;
                                }

                                return QuizCard(
                                  title: quiz.title,
                                  questionsCount: quiz.totalQuestions,
                                  timeLimit: quiz.timeLimitMinutes,
                                  score: latestResult?.scorePercentage,
                                  isLocked: quiz.isLocked,
                                  onStartQuiz: !quiz.isLocked && latestResult == null
                                      ? () {
                                          Navigator.pushNamed(
                                            context,
                                            '/quiz/question',
                                            arguments: quiz.id,
                                          );
                                        }
                                      : null,
                                  onRetakeQuiz: latestResult != null
                                      ? () {
                                          Navigator.pushNamed(
                                            context,
                                            '/quiz/question',
                                            arguments: quiz.id,
                                          );
                                        }
                                      : null,
                                  onViewResults: latestResult != null
                                      ? () {
                                          Navigator.pushNamed(
                                            context,
                                            '/quiz/completion',
                                            arguments: {
                                              'correctAnswers': latestResult!.correctAnswers,
                                              'totalQuestions': latestResult.totalQuestions,
                                              'scorePercentage': latestResult.scorePercentage,
                                              'quizId': latestResult.quizId,
                                              'courseId': widget.courseId,
                                            },
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
                                backgroundColor: AppColors.primary,
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
