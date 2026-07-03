import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/features/courses_student_side/data/repositories/course_repository_impl.dart';
import 'package:learning_management_system/features/courses_student_side/domain/use_cases/get_courses_use_case.dart';
import '../../../data/data_sources/courses_remote_data_source.dart';
import '../../../data/models/section_model.dart';
import '../../../domain/use_cases/get_sections_use_case.dart';

import '../widgets/course_details/course_header_widget.dart';
import '../widgets/course_details/enroll_button_widget.dart';
import '../widgets/course_details/about_course_widget.dart';
import '../widgets/course_details/section_card_widget.dart';

class CourseDetailsScreen extends StatefulWidget {
  final dynamic course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Future<List<SectionModel>> sectionsFuture;

  @override
  void initState() {
    super.initState();

    final remoteDataSource = FirebaseCoursesRemoteDataSource(
      FirebaseFirestore.instance,
    );

    final repository = CourseRepositoryImpl(remoteDataSource);

    final getSectionsUseCase = GetSectionsUseCase(repository);

    sectionsFuture = getSectionsUseCase(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CourseHeaderWidget(
                title: widget.course.title,
                instructor: widget.course.instructor,
              ),

              const SizedBox(height: 22),

              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .doc(widget.course.id)
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
                  }
                  
                  final isEnrolled = snapshot.hasData && snapshot.data!.exists;
                  
                  if (isEnrolled) {
                    // Hide the enroll button if already enrolled
                    return const SizedBox();
                  }
                  
                  return EnrollButtonWidget(
                    onTap: () {
                      final remoteDataSource = FirebaseCoursesRemoteDataSource(
                        FirebaseFirestore.instance,
                      );
                      final repository = CourseRepositoryImpl(remoteDataSource);
                      final coursesUseCase = CoursesUseCase(repository);
                      coursesUseCase.courseEnroll(widget.course.id);
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              AboutCourseWidget(description: widget.course.description),

              const SizedBox(height: 28),

              FutureBuilder<List<SectionModel>>(
                future: sectionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sections = snapshot.data ?? [];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Course Content",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "${sections.length} sections",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          final section = sections[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SectionCardWidget(
                              courseId: widget.course.id,
                              sectionId: section.id,
                              title: section.title,
                              items: section.duration,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
