import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_state.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_state.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/course_list_tech.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/quick_stats_card.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/top_section_tech.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/screens/teacher_create_course_screen.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_cubit.dart';
import 'package:learning_management_system/features/courses_teacher_side/data/data_sources/teacher_courses_remote_data_source_impl.dart';
import 'package:learning_management_system/features/courses_teacher_side/data/repositories/teacher_course_repository_impl.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/add_course_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/add_lesson_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/add_section_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/delete_course_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/delete_lesson_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/delete_section_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/update_course_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/update_lesson_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/update_section_use_case.dart';

class HomeScreenTech extends StatefulWidget {
  const HomeScreenTech({super.key});

  @override
  State<HomeScreenTech> createState() => _HomeScreenTechState();
}

class _HomeScreenTechState extends State<HomeScreenTech> {
  @override
  void initState() {
    super.initState();
    // Initialize HomeCubit with user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthSuccess || authState is AuthSignUpSuccess) {
        final userData = authState is AuthSuccess
            ? authState.userData
            : (authState as AuthSignUpSuccess).userData;
        if (userData != null) {
          // Update the HomeCubit with current user data
          context.read<HomeCubit>().updateUser(userData);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              final firebaseDataSource =
                                  FirebaseTeacherCoursesRemoteDataSource(
                                    FirebaseFirestore.instance,
                                  );
                              final repo = TeacherCourseRepositoryImpl(
                                firebaseDataSource,
                              );
                              final cubit = TeacherCourseCubit(
                                addCourseUseCase: AddCourseUseCase(repo),
                                updateCourseUseCase: UpdateCourseUseCase(repo),
                                deleteCourseUseCase: DeleteCourseUseCase(repo),
                                addSectionUseCase: AddSectionUseCase(repo),
                                updateSectionUseCase: UpdateSectionUseCase(
                                  repo,
                                ),
                                deleteSectionUseCase: DeleteSectionUseCase(
                                  repo,
                                ),
                                addLessonUseCase: AddLessonUseCase(repo),
                                updateLessonUseCase: UpdateLessonUseCase(repo),
                                deleteLessonUseCase: DeleteLessonUseCase(repo),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: const TeacherCreateCourseScreen(),
                                  ),
                                ),
                              );
                            },
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
                          QuickStatsCard(
                            completionRate: state.quickStats.completionRate,
                            newEnrollments: state.quickStats.newEnrollments,
                          ),
                          const SizedBox(height: 24),
                          CourseListTech(
                            courses: state.courses,
                            onViewAll: () {
                              // Navigate to courses screen
                              Navigator.pushNamed(context, '/teacher-courses');
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

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
