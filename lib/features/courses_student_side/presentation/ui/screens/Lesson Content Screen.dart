import 'package:flutter/material.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/widgets/lesson/complete_button_widget.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/widgets/lesson/lesson_description_widget.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/widgets/lesson/takeaways_widget.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/widgets/lesson/video_player_widget.dart';

class LessonContentScreen extends StatelessWidget {
  const LessonContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const VideoPlayerWidget(),

              const SizedBox(height: 24),

              const LessonDescriptionWidget(),

              const SizedBox(height: 22),

              const TakeawaysWidget(),

              const SizedBox(height: 28),

              const CompleteButtonWidget(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
