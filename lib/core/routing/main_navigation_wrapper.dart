import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/auth/data/models/user_model.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/home_screen_student.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/home_screen_tech.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/screens/student_courses_screen.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/screens/teacher_courses_screen.dart';
import 'package:learning_management_system/features/chat/presentation/ui/screens/chat_screen.dart';
import 'package:learning_management_system/features/profile/presentation/screens/student_profile_screen.dart';
import 'package:learning_management_system/features/profile/presentation/screens/teacher_profile_screen.dart';
import 'package:learning_management_system/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:learning_management_system/features/profile/presentation/cubit/profile_state.dart';
import 'package:learning_management_system/features/profile/domain/entities/profile_entity.dart';

class MainNavigationWrapper extends StatefulWidget {
  final UserModel userData;

  const MainNavigationWrapper({super.key, required this.userData});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  late final bool _isStudent = widget.userData.role == 'Student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _buildScreens()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _isStudent ? Colors.blue : const Color(0xFF5B93F5),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScreens() {
    if (_isStudent) {
      return [
        const HomeScreenStudent(),
        const StudentCoursesScreen(),
        const ChatScreen(),
        _StudentProfileWrapper(userData: widget.userData),
      ];
    } else {
      return [
        const HomeScreenTech(),
        const TeacherCoursesScreen(),
        const ChatScreen(),
        _TeacherProfileWrapper(userData: widget.userData),
      ];
    }
  }
}

// Wrapper for student profile to handle ProfileEntity
class _StudentProfileWrapper extends StatelessWidget {
  final UserModel userData;

  const _StudentProfileWrapper({required this.userData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileLoaded) {
          return StudentProfileScreen(profile: state.profile);
        }

        if (state is ProfileError) {
          return Scaffold(body: Center(child: Text('Error: ${state.message}')));
        }

        // Fallback with mock data
        final profile = ProfileEntity(
          uid: userData.uid,
          fullName: userData.fullName,
          email: userData.email,
          role: userData.role,
          studentStats: const StudentStats(
            enrolled: 8,
            completed: 12,
            certificates: 5,
            avgScore: 87.0,
          ),
        );

        return StudentProfileScreen(profile: profile);
      },
    );
  }
}

// Wrapper for teacher profile to handle ProfileEntity
class _TeacherProfileWrapper extends StatelessWidget {
  final UserModel userData;

  const _TeacherProfileWrapper({required this.userData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileLoaded) {
          return TeacherProfileScreen(profile: state.profile);
        }

        if (state is ProfileError) {
          return Scaffold(body: Center(child: Text('Error: ${state.message}')));
        }

        // Fallback with mock data
        final profile = ProfileEntity(
          uid: userData.uid,
          fullName: userData.fullName,
          email: userData.email,
          role: userData.role,
          teacherStats: const TeacherStats(
            courses: 8,
            students: 546,
            rating: 4.8,
            issued: 15,
          ),
        );

        return TeacherProfileScreen(profile: profile);
      },
    );
  }
}
