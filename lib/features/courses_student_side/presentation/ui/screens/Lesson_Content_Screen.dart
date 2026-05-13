import 'package:flutter/material.dart';

import '../widgets/lesson/video_player_widget.dart';
import '../widgets/lesson/lesson_description_widget.dart';
import '../widgets/lesson/takeaways_widget.dart';
import '../widgets/lesson/complete_button_widget.dart';

class LessonContentScreen extends StatelessWidget {
  const LessonContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              VideoPlayerWidget(),

              SizedBox(height: 24),

              LessonDescriptionWidget(),

              SizedBox(height: 22),

              TakeawaysWidget(),

              SizedBox(height: 28),

              CompleteButtonWidget(),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
