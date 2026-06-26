import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../data/data_sources/courses_remote_data_source.dart';
import '../../../data/repositories/course_repository_impl.dart';
import '../../../domain/use_cases/get_courses_use_case.dart';

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
  List allCourses = [];
  String searchText = '';

  final TextEditingController searchController = TextEditingController();

  late Future<dynamic> coursesFuture;

  @override
  void initState() {
    super.initState();

    print('StudentCoursesScreen Opened');

    final remoteDataSource = FirebaseCoursesRemoteDataSource(
      FirebaseFirestore.instance,
    );

    final repository = CourseRepositoryImpl(remoteDataSource);

    final getCoursesUseCase = GetCoursesUseCase(repository);

    coursesFuture = getCoursesUseCase();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CoursesHeaderWidget(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value.trim().toLowerCase();
                  });
                },
              ),

              const SizedBox(height: 24),

              FutureBuilder(
                future: coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('ERROR: ${snapshot.error}');

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(snapshot.error.toString()),
                    );
                  }

                  final courses = snapshot.data as List? ?? [];

                  allCourses = List.from(courses);

                  final filteredCourses = allCourses.where((course) {
                    return course.title.toLowerCase().contains(searchText);
                  }).toList();

                  print('COURSES RECEIVED: ${courses.length}');

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

                      if (filteredCourses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No Courses Found',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = filteredCourses[index];

                            return CourseCardWidget(
                              title: course.title,
                              instructor: course.instructor,
                              image: course.image,
                              studentsCount: course.studentsCount,
                              rating: course.rating,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CourseDetailsScreen(course: course),
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
