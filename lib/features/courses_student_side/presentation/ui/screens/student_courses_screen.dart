import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';

import '../../../data/data_sources/courses_remote_data_source.dart';
import '../../../data/repositories/course_repository_impl.dart';
import '../../../domain/use_cases/get_courses_use_case.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  List<CourseModel> coursesEnrolled = [];
  List<CourseModel> coursesAvailable = [];
  List<CourseModel> coursesShow = [];
  bool isEnrolledSelected = false;

  late Future<void> _coursesFuture;

  Future<void> getCourses() async {
    final remoteDataSource = FirebaseCoursesRemoteDataSource(
      FirebaseFirestore.instance,
    );

    final repository = CourseRepositoryImpl(remoteDataSource);

    final getCoursesUseCase = CoursesUseCase(repository);

    coursesAvailable = await getCoursesUseCase.getCourses();

    if (FirebaseAuth.instance.currentUser != null) {
      coursesEnrolled = await getCoursesUseCase.getEnrolledCourses();
    } else {
      coursesEnrolled = [];
    }

    coursesShow = coursesAvailable;
  }
  StreamSubscription<QuerySnapshot>? _availableCoursesSubscription;
  StreamSubscription<QuerySnapshot>? _enrolledCoursesSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('StudentCoursesScreen Opened');
    _setupStreams();
  }

  void _setupStreams() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        coursesAvailable = [];
        coursesEnrolled = [];
        coursesShow = [];
      });
      return;
    }

    // Listen to available courses
    _availableCoursesSubscription = FirebaseFirestore.instance
        .collection('courses')
        .snapshots()
        .listen(
          (snapshot) {
            final courses = snapshot.docs.map((doc) {
              final data = doc.data();
              return CourseModel.fromJson(data, doc.id);
            }).toList();

            setState(() {
              coursesAvailable = courses;
              if (!isEnrolledSelected) {
                coursesShow = courses;
              }
              _isLoading = false;
            });
          },
          onError: (e) {
            print('Error loading available courses: $e');
          },
        );

    // Listen to enrolled courses
    _enrolledCoursesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('courses')
        .snapshots()
        .listen(
          (snapshot) async {
            final courseIds = snapshot.docs.map((doc) => doc.id).toList();

            if (courseIds.isEmpty) {
              setState(() {
                coursesEnrolled = [];
                if (isEnrolledSelected) {
                  coursesShow = [];
                }
              });
              return;
            }

            // Fetch course details for enrolled courses
            final coursesSnapshot = await FirebaseFirestore.instance
                .collection('courses')
                .where(FieldPath.documentId, whereIn: courseIds)
                .get();

            final courses = coursesSnapshot.docs.map((doc) {
              final data = doc.data();
              return CourseModel.fromJson(data, doc.id);
            }).toList();

            setState(() {
              coursesEnrolled = courses;
              if (isEnrolledSelected) {
                coursesShow = courses;
              }
            });
          },
          onError: (e) {
            print('Error loading enrolled courses: $e');
          },
        );
  }

  @override
  void dispose() {
    searchController.dispose();
    _availableCoursesSubscription?.cancel();
    _enrolledCoursesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    allCourses = List.from(coursesShow);
    final filteredCourses = allCourses.where((course) {
      return course.title.toLowerCase().contains(searchText);
    }).toList();

    print('COURSES RECEIVED: ${coursesAvailable.length}');

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

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    CourseTabsWidget(
                      enrolledCount: coursesEnrolled.length,
                      availableCount: coursesAvailable.length,
                      isEnrolledSelected: isEnrolledSelected,
                      onEnrolledTap: () {
                        setState(() {
                          coursesShow = coursesEnrolled;
                          isEnrolledSelected = true;
                        });
                      },
                      onAvailableTap: () {
                        setState(() {
                          coursesShow = coursesAvailable;
                          isEnrolledSelected = false;
                        });
                      },
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
