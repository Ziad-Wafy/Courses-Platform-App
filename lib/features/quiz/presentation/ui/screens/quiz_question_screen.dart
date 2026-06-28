import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_color.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../cubit/quiz_cubit.dart';
import '../../../domain/entities/quiz_entity.dart';

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

  @override
  void initState() {
    super.initState();
    quizCubit = sl<QuizCubit>();
    quizCubit.getQuizById(widget.quizId);
    startTime = DateTime.now();
  }

  void _startTimer(int minutes) {
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
    final state = quizCubit.state;
    if (user != null && state is QuizLoaded) {
      final quiz = state.quiz;
      final studentAnswers = List.generate(quiz.questions.length, (i) => StudentAnswer(
        questionId: quiz.questions[i].id,
        selectedAnswerId: answers[i] ?? '',
        isCorrect: false,
      ));
      final timeSpent = DateTime.now().difference(startTime!).inSeconds;
      quizCubit.submitAnswers(quiz.id, user.uid, studentAnswers, timeSpent);
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
                'courseId': (quizCubit.state as QuizLoaded).quiz.courseId,
              });
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) return const Center(child: CircularProgressIndicator());
            if (state is QuizLoaded) {
              final quiz = state.quiz;
              if (timer == null) _startTimer(quiz.timeLimitMinutes);
              final question = quiz.questions[currentIndex];

              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: (currentIndex + 1) / quiz.questions.length),
                    SizedBox(height: 24.h),
                    Text('Question ${currentIndex + 1}/${quiz.questions.length}', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
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
                            if (currentIndex < quiz.questions.length - 1) {
                              setState(() => currentIndex++);
                            } else {
                              _submit();
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          child: Text(currentIndex < quiz.questions.length - 1 ? 'Next' : 'Submit'),
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
