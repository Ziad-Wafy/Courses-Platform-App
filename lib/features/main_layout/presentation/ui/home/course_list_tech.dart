import 'package:flutter/material.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/course_list_item_tech.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';

class CourseListTech extends StatelessWidget {
  final List<TeacherCourseData> courses;
  final VoidCallback? onViewAll;

  const CourseListTech({super.key, required this.courses, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 8),
        ...courses.map(
          (c) => InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/course-details',
                arguments: c,
              );
            },
            child: CourseListItemTech(
              title: c.title,
              studentCount: c.studentCount,
              completionPercent: c.completionPercent,
              icon: c.icon,
              iconColor: c.iconColor,
            ),
          ),
        ),
      ],
    );
  }
}
