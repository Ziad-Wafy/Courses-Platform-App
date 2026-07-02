import 'package:flutter/material.dart';
import 'package:test_app/widegets/home/course_list_item.dart';

class CourseList extends StatelessWidget {
  const CourseList({super.key});

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
              Row(
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(color: Color(0xFF5596F6), fontSize: 14),
                  ),
                  Icon(Icons.chevron_right, color: Color(0xFF5596F6), size: 18),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          const CourseListItem(
            icon: Icons.language,
            title: 'Web Development\nFundamentals',
            subtitle: 'Dr. Sarah Johnson',
            progress: 0.65,
            progressText: '65%',
          ),
          const SizedBox(height: 16),
          const CourseListItem(
            icon: Icons.laptop_chromebook,
            title: 'Data Structures & Algorithms',
            subtitle: 'Prof. Michael Chen',
            progress: 0.40,
            progressText: '40%',
          ),
          const SizedBox(height: 16),
          const CourseListItem(
            icon: Icons.smartphone,
            title: 'Mobile App Design',
            subtitle: 'Dr. Emily Rodriguez',
            progress: 0.80,
            progressText: '80%',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
