import 'package:flutter/material.dart';

import '../widgets/courses/courses_header_widget.dart';
import '../widgets/courses/course_tabs_widget.dart';

class StudentCoursesScreen extends StatelessWidget {
  const StudentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Header + Search
              CoursesHeaderWidget(
                controller: searchController,
                onChanged: (value) {},
              ),

              const SizedBox(height: 24),

              /// Tabs
              CourseTabsWidget(
                enrolledCount: 0,
                availableCount: 0,
                isEnrolledSelected: true,
                onEnrolledTap: () {},
                onAvailableTap: () {},
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
