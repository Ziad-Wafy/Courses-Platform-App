import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/common_widgets.dart';

class QuizCompletionScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final double scorePercentage;
  final String quizId;
  final String courseid;

  const QuizCompletionScreen({
    Key? key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.quizId,
    required this.courseid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final passed = scorePercentage >= 60;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4A90E2),
                    const Color(0xFF357ABD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events,
                        size: 48.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    passed ? 'Congratulations!' : 'Quiz Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    passed
                        ? 'You passed the quiz'
                        : 'You did not pass this quiz',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            ResultCard(
              correctAnswers: correctAnswers,
              totalQuestions: totalQuestions,
              scorePercentage: scorePercentage,
              passed: passed,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: passed
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFFFC107).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: passed
                      ? const Color(0xFF4CAF50).withOpacity(0.3)
                      : const Color(0xFFFFC107).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    passed ? Icons.check_circle : Icons.info,
                    color: passed
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFFC107),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      passed
                          ? '🎉 Great job! You\'ve successfully completed this quiz.'
                          : 'You can retake this quiz to improve your score.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/quiz/question',
                        arguments: quizId,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake Quiz'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      side: const BorderSide(
                        color: Color(0xFF4A90E2),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/quiz/list',
                        arguments: courseid,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Quizzes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
