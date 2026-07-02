import 'package:flutter/material.dart';
import 'package:test_app/widegets/home/top_section.dart';
import 'package:test_app/widegets/home/continue_learning_card.dart';
import 'package:test_app/widegets/home/course_list.dart';

class HomeScreenStudent extends StatelessWidget {
  const HomeScreenStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopSection(),
            SizedBox(height: 24),
            ContinueLearningCard(),
            SizedBox(height: 24),
            CourseList(),
          ],
        ),
      ),
    );
  }
}
