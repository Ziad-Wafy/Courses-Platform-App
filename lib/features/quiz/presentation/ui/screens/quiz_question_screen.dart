import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:learning_management_system/core/theme/app_color.dart';
import 'package:learning_management_system/core/utils/service_locator.dart';
import 'package:learning_management_system/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:learning_management_system/features/quiz/domain/entities/quiz_entity.dart';

class QuizQuestionScreen extends StatefulWidget {
  final String quizId;
  const QuizQuestionScreen({super.key, required this.quizId});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  late QuizCubit quizCubit;
  Timer? timer;
  int remainingSeconds = 0;
  int currentIndex = 0;
  final Map<int, String> answers = {};
  DateTime? startTime;
  String? cachedCourseId;

  @override
  void initState() {
    super.initState();
    quizCubit = sl<QuizCubit>();
    quizCubit.getQuizById(widget.quizId);
    startTime = DateTime.now();
  }

  void _startTimer(int minutes) {
    if (timer != null) return;
    remainingSeconds = minutes * 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        if (mounted) setState(() => remainingSeconds--);
      } else {
        t.cancel();
        _submit();
      }
    });
  }

  void _submit() {
    timer?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final state = quizCubit.state;
      if (state is QuizLoaded) {
        final studentAnswers = List.generate(state.quiz.questions.length, (i) => StudentAnswer(
          questionId: state.quiz.questions[i].id,
          selectedAnswerId: answers[i] ?? '',
          isCorrect: false,
        ));
        final timeSpent = DateTime.now().difference(startTime!).inSeconds;
        quizCubit.submitAnswers(state.quiz.id, user.uid, studentAnswers, timeSpent);
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: quizCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Taking Quiz'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            if (remainingSeconds > 0)
              Center(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text('${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, "0")}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ))
          ],
        ),
        body: BlocConsumer<QuizCubit, QuizState>(
          listener: (context, state) {
            if (state is QuizAnswersSubmitted) {
              Navigator.pushReplacementNamed(context, '/quiz/completion', arguments: {
                'correctAnswers': state.result.correctAnswers,
                'totalQuestions': state.result.totalQuestions,
                'scorePercentage': state.result.scorePercentage,
                'quizId': state.result.quizId,
                'courseId': cachedCourseId ?? '',
              });
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) return const Center(child: CircularProgressIndicator());
            if (state is QuizError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            
            if (state is QuizLoaded) {
              cachedCourseId = state.quiz.courseId;
              _startTimer(state.quiz.timeLimitMinutes);
              final question = state.quiz.questions[currentIndex];

              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: (currentIndex + 1) / state.quiz.questions.length),
                    SizedBox(height: 24.h),
                    Text('Question ${currentIndex + 1}/${state.quiz.questions.length}', style: const TextStyle(color: Colors.grey)),
                    SizedBox(height: 8.h),
                    Text(question.text, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 24.h),
                    Expanded(child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, i) {
                        final option = question.options[i];
                        return RadioListTile<String>(
                          title: Text(option.text),
                          value: option.id,
                          groupValue: answers[currentIndex],
                          onChanged: (val) => setState(() => answers[currentIndex] = val!),
                        );
                      },
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentIndex > 0) ElevatedButton(onPressed: () => setState(() => currentIndex--), child: const Text('Back')),
                        ElevatedButton(
                          onPressed: () {
                            if (currentIndex < state.quiz.questions.length - 1) {
                              setState(() => currentIndex++);
                            } else {
                              _submit();
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          child: Text(currentIndex < state.quiz.questions.length - 1 ? 'Next' : 'Submit'),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
