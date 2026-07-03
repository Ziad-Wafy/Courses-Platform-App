import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_management_system/features/auth/data/models/user_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FirebaseFirestore firestore;
  UserModel currentUser;
  StreamSubscription? _coursesSubscription;
  StreamSubscription? _userSubscription;

  HomeCubit({required this.firestore, required this.currentUser})
    : super(HomeInitial()) {
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      // Fetch user-specific data based on role
      if (currentUser.role == 'Student') {
        _fetchStudentDataStream();
      } else {
        _fetchTeacherDataStream();
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  void _fetchStudentDataStream() {
    // Listen to enrolled courses for student
    _coursesSubscription = firestore
        .collection('courses')
        .where('enrolledStudents', arrayContains: currentUser.uid)
        .snapshots()
        .listen(
          (snapshot) {
            final courses = snapshot.docs.map((doc) {
              final data = doc.data();
              return CourseData(
                id: doc.id,
                title: data['title'] ?? '',
                instructor: data['instructorName'] ?? '',
                progress: _calculateProgress(data),
                progressText: '${_calculateProgress(data) * 100}%',
                icon: _getIconForCourse(data['category'] ?? 'general'),
              );
            }).toList();

            // Listen to user stats
            _userSubscription = firestore
                .collection('users')
                .doc(currentUser.uid)
                .snapshots()
                .listen(
                  (userDoc) {
                    final userData = userDoc.data();

                    final stats = UserStats(
                      courses: courses.length,
                      completed: userData?['completedCourses'] ?? 0,
                      progress: userData?['averageProgress'] ?? 0.0,
                    );

                    // Get continue learning course (most recent or least completed)
                    final continueLearningCourse = courses.isNotEmpty
                        ? courses.reduce(
                            (a, b) => a.progress < b.progress ? a : b,
                          )
                        : null;

                    emit(
                      StudentHomeLoaded(
                        courses: courses,
                        stats: stats,
                        continueLearningCourse: continueLearningCourse,
                        userName: currentUser.fullName,
                      ),
                    );
                  },
                  onError: (e) {
                    emit(HomeError(message: e.toString()));
                  },
                );
          },
          onError: (e) {
            emit(HomeError(message: e.toString()));
          },
        );
  }

  void _fetchTeacherDataStream() {
    // Listen to courses created by teacher
    _coursesSubscription = firestore
        .collection('courses')
        .where('instructorId', isEqualTo: currentUser.uid)
        .snapshots()
        .listen(
          (snapshot) {
            final courses = snapshot.docs.map((doc) {
              final data = doc.data();
              return TeacherCourseData(
                id: doc.id,
                title: data['title'] ?? '',
                studentCount: data['enrolledStudents']?.length ?? 0,
                completionPercent: data['averageCompletion'] ?? 0,
                icon: _getIconForCourse(data['category'] ?? 'general'),
                iconColor: const Color(0xFF5B93F5),
              );
            }).toList();

            // Listen to teacher stats
            _userSubscription = firestore
                .collection('users')
                .doc(currentUser.uid)
                .snapshots()
                .listen(
                  (userDoc) {
                    final userData = userDoc.data();

                    final teacherStats = TeacherStats(
                      courseCount: courses.length,
                      studentCount: _calculateTotalStudents(courses),
                      rating: userData?['rating'] ?? 4.0,
                    );

                    // Fetch quick stats
                    final quickStats = QuickStats(
                      completionRate:
                          '${_calculateAverageCompletion(courses)}%',
                      newEnrollments:
                          '${_calculateNewEnrollments(currentUser.uid)}',
                    );

                    emit(
                      TeacherHomeLoaded(
                        courses: courses,
                        stats: teacherStats,
                        quickStats: quickStats,
                        userName: currentUser.fullName,
                      ),
                    );
                  },
                  onError: (e) {
                    emit(HomeError(message: e.toString()));
                  },
                );
          },
          onError: (e) {
            emit(HomeError(message: e.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _coursesSubscription?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }

  void updateUser(UserModel newUser) {
    if (currentUser.uid != newUser.uid) {
      // Different user, restart streams
      _coursesSubscription?.cancel();
      _userSubscription?.cancel();
      currentUser = newUser;
      fetchHomeData();
    }
  }

  double _calculateProgress(Map<String, dynamic> courseData) {
    // Calculate progress based on completed lessons vs total lessons
    final totalLessons = courseData['totalLessons'] ?? 1;
    final completedLessons = courseData['completedLessons'] ?? 0;
    return completedLessons / totalLessons;
  }

  IconData _getIconForCourse(String category) {
    switch (category.toLowerCase()) {
      case 'web':
      case 'development':
        return Icons.language;
      case 'mobile':
        return Icons.smartphone;
      case 'data':
      case 'database':
        return Icons.storage;
      case 'design':
        return Icons.palette;
      default:
        return Icons.menu_book;
    }
  }

  int _calculateTotalStudents(List<TeacherCourseData> courses) {
    return courses.fold(0, (sum, course) => sum + course.studentCount);
  }

  double _calculateAverageCompletion(List<TeacherCourseData> courses) {
    if (courses.isEmpty) return 0.0;
    final total = courses.fold(
      0.0,
      (sum, course) => sum + course.completionPercent,
    );
    return total / courses.length;
  }

  int _calculateNewEnrollments(String teacherId) {
    // This would need a more complex query with date filtering
    // For now, return a placeholder
    return 0;
  }
}

// Data models
class CourseData {
  final String id;
  final String title;
  final String instructor;
  final double progress;
  final String progressText;
  final IconData icon;

  CourseData({
    required this.id,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.progressText,
    required this.icon,
  });
}

class TeacherCourseData {
  final String id;
  final String title;
  final int studentCount;
  final int completionPercent;
  final IconData icon;
  final Color iconColor;

  TeacherCourseData({
    required this.id,
    required this.title,
    required this.studentCount,
    required this.completionPercent,
    required this.icon,
    required this.iconColor,
  });
}

class UserStats {
  final int courses;
  final int completed;
  final double progress;

  UserStats({
    required this.courses,
    required this.completed,
    required this.progress,
  });
}

class TeacherStats {
  final int courseCount;
  final int studentCount;
  final double rating;

  TeacherStats({
    required this.courseCount,
    required this.studentCount,
    required this.rating,
  });
}

class QuickStats {
  final String completionRate;
  final String newEnrollments;

  QuickStats({required this.completionRate, required this.newEnrollments});
}
