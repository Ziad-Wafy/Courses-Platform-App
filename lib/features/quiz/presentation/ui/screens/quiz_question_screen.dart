import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/service_locator.dart';
import '../../cubit/quiz_cubit.dart';
import '../widgets/common_widgets.dart';

class QuizQuestionScreen extends StatefulWidget {
  final String quizId;

  const QuizQuestionScreen({
    Key? key,
    required this.quizId,
  }) : super(key: key);

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  late QuizCubit quizCubit;
  late Timer timer;
  int remainingSeconds = 0;
  int currentQuestionIndex = 0;
  late Map<int, String> answers; // Maps question index to selected answer ID

  @override
  void initState() {
    super.initState();
    quizCubit = sl<QuizCubit>();
    quizCubit.getQuizById(widget.quizId);
    answers = {};
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() {
    timer.cancel();
    // TODO: Submit answers and navigate to results
    Navigator.pushNamed(context, '/quiz/completion');
  }

  @override
  void dispose() {
    timer.cancel();
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
            if (state is QuizError) {
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
                      const Color(0xFF4A90E2),
                    ),
                  ),
                );
              }

              if (state is QuizLoaded) {
                final quiz = state.quiz;

                // Initialize timer on first load
                if (remainingSeconds == 0) {
                  remainingSeconds = quiz.timeLimitMinutes * 60;
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
                                                ? const Color(0xFF4A90E2)
                                                    .withOpacity(0.1)
                                                : Colors.white,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF4A90E2)
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
                                                        ? const Color(0xFF4A90E2)
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
                                                          color: Color(
                                                              0xFF4A90E2),
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
                                                        ? const Color(0xFF4A90E2)
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
                                    color: Color(0xFF4A90E2),
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
                                    color: const Color(0xFF4A90E2),
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
                                backgroundColor: const Color(0xFF4A90E2),
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
