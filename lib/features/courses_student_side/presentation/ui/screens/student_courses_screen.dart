import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:learning_management_system/features/courses_student_side/data/data_sources/courses_remote_data_source.dart';
import 'package:learning_management_system/features/courses_student_side/data/repositories/course_repository_impl.dart';
import 'package:learning_management_system/features/courses_student_side/domain/use_cases/get_courses_use_case.dart';

import '../widgets/courses/course_card_widget.dart';
import '../widgets/courses/course_tabs_widget.dart';
import '../widgets/courses/courses_header_widget.dart';

import 'course_details_screen.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  late Future<dynamic> coursesFuture;

  @override
  void initState() {
    super.initState();

    final remoteDataSource = FirebaseCoursesRemoteDataSource(
      FirebaseFirestore.instance,
    );

    final repository = CourseRepositoryImpl(remoteDataSource);

    final getCoursesUseCase = GetCoursesUseCase(repository);

    coursesFuture = getCoursesUseCase();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CoursesHeaderWidget(
                controller: searchController,
                onChanged: (value) {},
              ),

              const SizedBox(height: 24),

              FutureBuilder(
                future: coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(snapshot.error.toString()),
                    );
                  }

                  final courses = snapshot.data as List? ?? [];

                  if (courses.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No Courses Found'),
                    );
                  }

                  return Column(
                    children: [
                      CourseTabsWidget(
                        enrolledCount: 0,
                        availableCount: courses.length,
                        isEnrolledSelected: true,
                        onEnrolledTap: () {},
                        onAvailableTap: () {},
                      ),

                      const SizedBox(height: 30),

                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];

                          return CourseCardWidget(
                            title: course.title,
                            instructor: course.instructor,
                            image: course.image,
                            studentsCount:
                                course.studentsCount,
                            rating: course.rating,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CourseDetailsScreen(
                                    course: course,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}