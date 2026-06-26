import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_color.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../cubit/quiz_cubit.dart';
import '../../domain/entities/quiz_entity.dart';
import '../widgets/common_widgets.dart';

class QuizQuestionScreen extends StatefulWidget {
  final String quizId;

  const QuizQuestionScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  late QuizCubit quizCubit;
  late Timer timer;
  int remainingSeconds = 0;
  int currentQuestionIndex = 0;
  late Map<int, String> answers; // Maps question index to selected answer ID
  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    quizCubit = sl<QuizCubit>();
    quizCubit.getQuizById(widget.quizId);
    answers = {};
    startTime = DateTime.now();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() {
    if (timer.isActive) {
      timer.cancel();
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User session expired. Please log in again.')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final studentId = currentUser.uid;
    final quizState = quizCubit.state;
    final timeSpentSeconds = DateTime.now().difference(startTime).inSeconds;

    if (quizState is QuizLoaded) {
      final quiz = quizState.quiz;
      final studentAnswers = <StudentAnswer>[];

      for (int i = 0; i < quiz.questions.length; i++) {
        studentAnswers.add(
          StudentAnswer(
            questionId: quiz.questions[i].id,
            selectedAnswerId: answers[i] ?? '',
            isCorrect: false, // Calculated in repository
          ),
        );
      }

      quizCubit.submitAnswers(quiz.id, studentId, studentAnswers, timeSpentSeconds);
    }
  }

  @override
  void dispose() {
    if (this.timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocProvider.value(
        value: quizCubit,
        child: BlocListener<QuizCubit, QuizState>(
          listener: (context, state) {
            if (state is QuizAnswersSubmitted) {
              Navigator.pushReplacementNamed(
                context,
                '/quiz/completion',
                arguments: {
                  'correctAnswers': state.result.correctAnswers,
                  'totalQuestions': state.result.totalQuestions,
                  'scorePercentage': state.result.scorePercentage,
                  'quizId': state.result.quizId,
                  'courseId': (quizCubit.state as QuizLoaded).quiz.courseId,
                },
              );
            } else if (state is QuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
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

              if (state is QuizLoaded) {
                final quiz = state.quiz;

                if (quiz.questions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz, size: 64.sp, color: Colors.grey),
                        SizedBox(height: 16.h),
                        const Text("This quiz has no questions."),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Go Back"),
                        ),
                      ],
                    ),
                  );
                }

                // Initialize timer on first load
                if (remainingSeconds == 0) {
                  remainingSeconds = quiz.timeLimitMinutes * 60;
                  _startTimer();
                }

                if (currentQuestionIndex >= quiz.questions.length) {
                  currentQuestionIndex = quiz.questions.length - 1;
                }

                final currentQuestion = quiz.questions[currentQuestionIndex];

                return Column(
                  children: [
                    QuizHeader(
                      title: 'Exit Quiz',
                      onBackPressed: () {
                        _showExitConfirmation(context);
                      },
                    ),
                    ProgressBar(
                      currentQuestion: currentQuestionIndex + 1,
                      totalQuestions: quiz.questions.length,
                      remainingSeconds: remainingSeconds,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 16.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  currentQuestion.text,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                children: List.generate(
                                  currentQuestion.options.length,
                                  (index) {
                                    final option = currentQuestion.options[index];
                                    final isSelected =
                                        answers[currentQuestionIndex] == option.id;

                                    return Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 12.h),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            answers[currentQuestionIndex] =
                                                option.id;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(14.w),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                    .withOpacity(0.1)
                                                : Colors.white,
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey.shade200,
                                              width: isSelected ? 2 : 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 24.w,
                                                height: 24.w,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : Colors.grey.shade300,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: AppColors.primary,
                                                        ),
                                                        child: Center(
                                                          child: Container(
                                                            width: 8.w,
                                                            height: 8.w,
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Text(
                                                  option.text,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w500,
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentQuestionIndex > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    currentQuestionIndex--;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          if (currentQuestionIndex > 0) SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (currentQuestionIndex <
                                    quiz.questions.length - 1) {
                                  setState(() {
                                    currentQuestionIndex++;
                                  });
                                } else {
                                  _submitQuiz();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                currentQuestionIndex <
                                        quiz.questions.length - 1
                                    ? 'Next Question'
                                    : 'Submit Quiz',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        'Error loading quiz',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content:
            const Text('Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              timer.cancel();
              Navigator.pop(context); // Exit quiz
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
