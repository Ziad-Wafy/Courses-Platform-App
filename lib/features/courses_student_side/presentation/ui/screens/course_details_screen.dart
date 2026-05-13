import 'package:flutter/material.dart';

import '../widgets/course_details/course_header_widget.dart';
import '../widgets/course_details/enroll_button_widget.dart';
import '../widgets/course_details/about_course_widget.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CourseHeaderWidget(),

              const SizedBox(height: 22),

              const EnrollButtonWidget(),

              const SizedBox(height: 24),

              const AboutCourseWidget(),

              const SizedBox(height: 28),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Course Content",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "0 sections",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// Firebase later
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
