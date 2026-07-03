import 'package:flutter/material.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/course_list_item.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';

class CourseList extends StatelessWidget {
  final List<CourseData> courses;

  const CourseList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Courses',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  // Navigate to courses screen
                  Navigator.pushNamed(context, '/courses');
                },
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(color: Color(0xFF5596F6), fontSize: 14),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFF5596F6),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CourseListItem(
                icon: course.icon,
                title: course.title,
                subtitle: course.instructor,
                progress: course.progress,
                progressText: course.progressText,
                onTap: () {
                  // Navigate to course details
                  Navigator.pushNamed(
                    context,
                    '/course-details',
                    arguments: course.id,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
