import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_state.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_state.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/course_list_tech.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/quick_stats_card.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/top_section_tech.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/screens/teacher_create_course_screen.dart';

class HomeScreenTech extends StatelessWidget {
  const HomeScreenTech({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final userData =
            (authState is AuthSuccess || authState is AuthSignUpSuccess)
            ? (authState is AuthSuccess
                  ? authState.userData
                  : (authState as AuthSignUpSuccess).userData)
            : null;

        if (userData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider(
          create: (_) => HomeCubit(
            firestore: FirebaseFirestore.instance,
            currentUser: userData,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HomeError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is TeacherHomeLoaded) {
                  return SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TopSectionTech(
                            teacherName: state.userName,
                            courseCount: state.stats.courseCount,
                            studentCount: state.stats.studentCount,
                            rating: state.stats.rating,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TeacherCreateCourseScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create New Course'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      52,
                                    ),
                                    backgroundColor: const Color(0xFF5B93F5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                QuickStatsCard(
                                  completionRate:
                                      state.quickStats.completionRate,
                                  newEnrollments:
                                      state.quickStats.newEnrollments,
                                ),
                                const SizedBox(height: 24),
                                CourseListTech(
                                  courses: state.courses,
                                  onViewAll: () {
                                    // Navigate to courses screen
                                    Navigator.pushNamed(
                                      context,
                                      '/teacher-courses',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}
