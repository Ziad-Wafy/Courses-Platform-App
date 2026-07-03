import 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}

class StudentHomeLoaded extends HomeState {
  final List<CourseData> courses;
  final UserStats stats;
  final CourseData? continueLearningCourse;
  final String userName;

  StudentHomeLoaded({
    required this.courses,
    required this.stats,
    this.continueLearningCourse,
    required this.userName,
  });
}

class TeacherHomeLoaded extends HomeState {
  final List<TeacherCourseData> courses;
  final TeacherStats stats;
  final QuickStats quickStats;
  final String userName;

  TeacherHomeLoaded({
    required this.courses,
    required this.stats,
    required this.quickStats,
    required this.userName,
  });
}
