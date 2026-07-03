import 'package:flutter/material.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/course_list_item_tech.dart';

class CourseData {
  final String title;
  final int studentCount;
  final int completionPercent;
  final IconData icon;
  final Color iconColor;

  const CourseData({
    required this.title,
    required this.studentCount,
    required this.completionPercent,
    required this.icon,
    required this.iconColor,
  });
}

class CourseListTech extends StatelessWidget {
  final List<CourseData> courses;
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
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...courses.map(
          (c) => CourseListItemTech(
            title: c.title,
            studentCount: c.studentCount,
            completionPercent: c.completionPercent,
            icon: c.icon,
            iconColor: c.iconColor,
          ),
        ),
      ],
    );
  }
}
