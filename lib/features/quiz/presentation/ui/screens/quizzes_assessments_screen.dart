import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_color.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../cubit/quiz_cubit.dart';
import '../../../domain/entities/quiz_entity.dart';

class QuizzesAndAssessmentsScreen extends StatefulWidget {
  final String courseId;
  const QuizzesAndAssessmentsScreen({super.key, required this.courseId});

  @override
  State<QuizzesAndAssessmentsScreen> createState() => _QuizzesAndAssessmentsScreenState();
}

class _QuizzesAndAssessmentsScreenState extends State<QuizzesAndAssessmentsScreen> {
  late QuizCubit quizCubit;

  @override
  void initState() {
    super.initState();
    quizCubit = sl<QuizCubit>();
    quizCubit.getQuizzesByCourse(widget.courseId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      quizCubit.getStudentResults(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: quizCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quizzes'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            if (state is QuizLoading) return const Center(child: CircularProgressIndicator());
            if (state is QuizError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            
            if (state is QuizzesLoaded) {
              if (state.quizzes.isEmpty) return const Center(child: Text('No quizzes found.'));
              
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = state.quizzes[index];
                  final result = state.studentResults.where((r) => r.quizId == quiz.id).toList();
                  QuizResult? latest;
                  if(result.isNotEmpty) {
                    result.sort((a, b) => b.completedAt.compareTo(a.completedAt));
                    latest = result.first;
                  }

                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${quiz.totalQuestions} Questions • ${quiz.timeLimitMinutes} Min'),
                      trailing: latest != null 
                        ? Text('${latest.scorePercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                        : const Icon(Icons.chevron_right),
                      onTap: quiz.isLocked ? null : () {
                        Navigator.pushNamed(context, '/quiz/question', arguments: quiz.id);
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
