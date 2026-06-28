import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';

class QuizCompletionScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final double scorePercentage;
  final String quizId;
  final String courseId;

  const QuizCompletionScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.quizId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result'), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(scorePercentage >= 60 ? Icons.check_circle : Icons.error, 
                size: 80.sp, color: scorePercentage >= 60 ? Colors.green : Colors.red),
              SizedBox(height: 24.h),
              Text(scorePercentage >= 60 ? 'Congratulations!' : 'Try Again!', 
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              Text('Your Score: ${scorePercentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 20.sp)),
              Text('$correctAnswers out of $totalQuestions correct', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
              SizedBox(height: 40.h),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/quiz/list', arguments: courseId),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 50.h)),
                child: const Text('Back to Quizzes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
