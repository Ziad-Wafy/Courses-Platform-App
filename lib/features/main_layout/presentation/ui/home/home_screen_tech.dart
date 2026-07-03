import 'package:flutter/material.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/course_list_tech.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/quick_stats_card.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/top_section_tech.dart';

class HomeScreenTech extends StatefulWidget {
  const HomeScreenTech({super.key});

  @override
  State<HomeScreenTech> createState() => _HomeScreenTechState();
}

class _HomeScreenTechState extends State<HomeScreenTech> {
  int _navIndex = 0;

  final List<CourseData> _courses = const [
    CourseData(
      title: 'Web Development Fundamentals',
      studentCount: 145,
      completionPercent: 72,
      icon: Icons.public,
      iconColor: Color(0xFF5B93F5),
    ),
    CourseData(
      title: 'Advanced React Patterns',
      studentCount: 89,
      completionPercent: 65,
      icon: Icons.hub_outlined,
      iconColor: Color(0xFF9C6BF0),
    ),
    CourseData(
      title: 'Database Design',
      studentCount: 112,
      completionPercent: 58,
      icon: Icons.save_outlined,
      iconColor: Color(0xFF5BC0F5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopSectionTech(
                teacherName: 'Dr. Sarah Johnson',
                courseCount: 8,
                studentCount: 546,
                rating: 4.8,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Course'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: const Color(0xFF5B93F5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const QuickStatsCard(
                      completionRate: '89%',
                      newEnrollments: '142',
                    ),
                    const SizedBox(height: 24),
                    CourseListTech(courses: _courses),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5B93F5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
