import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/domain/use_cases/get_teacher_courses_use_case.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/widgets/courses/course_card_widget.dart';
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
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_cubit.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/screens/teacher_create_course_screen.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/screens/teacher_course_content_screen.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/widgets/teacher_shared_widgets.dart';

/// Entry point for the teacher side — lists all courses from Firestore.
class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  late final GetTeacherCoursesUseCase _getTeacherCoursesUseCase;

  @override
  void initState() {
    super.initState();
    final remoteDataSource = FirebaseTeacherCoursesRemoteDataSource(
      FirebaseFirestore.instance,
    );
    final repository = TeacherCourseRepositoryImpl(remoteDataSource);
    _getTeacherCoursesUseCase = GetTeacherCoursesUseCase(repository);
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final courses = uid != null
          ? await _getTeacherCoursesUseCase(uid)
          : <CourseModel>[];
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  TeacherCourseCubit _buildCubit() {
    final firebaseDataSource = FirebaseTeacherCoursesRemoteDataSource(
      FirebaseFirestore.instance,
    );
    final repo = TeacherCourseRepositoryImpl(firebaseDataSource);
    return TeacherCourseCubit(
      addCourseUseCase: AddCourseUseCase(repo),
      updateCourseUseCase: UpdateCourseUseCase(repo),
      deleteCourseUseCase: DeleteCourseUseCase(repo),
      addSectionUseCase: AddSectionUseCase(repo),
      updateSectionUseCase: UpdateSectionUseCase(repo),
      deleteSectionUseCase: DeleteSectionUseCase(repo),
      addLessonUseCase: AddLessonUseCase(repo),
      updateLessonUseCase: UpdateLessonUseCase(repo),
      deleteLessonUseCase: DeleteLessonUseCase(repo),
    );
  }

  void _navigateToContent(CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => _buildCubit(),
          child: TeacherCourseContentScreen(course: course),
        ),
      ),
    ).then((_) => _fetchCourses());
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => _buildCubit(),
          child: const TeacherCreateCourseScreen(),
        ),
      ),
    ).then((_) => _fetchCourses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _courses
        .where((c) => c.title.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: TeacherShared.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: const BoxDecoration(
                color: TeacherShared.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(TeacherShared.radiusXXL),
                  bottomRight: Radius.circular(TeacherShared.radiusXXL),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Courses',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage your course content',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: _navigateToCreate,
                          tooltip: 'Create New Course',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ── Search bar ──────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchText = v.trim()),
                      decoration: const InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchCourses,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 72,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchText.isEmpty
                                ? 'No courses yet.\nTap + to create your first course!'
                                : 'No courses match "$_searchText"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchCourses,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final course = filtered[index];
                          return Stack(
                            children: [
                              CourseCardWidget(
                                title: course.title,
                                instructor: course.instructor,
                                image: course.image,
                                studentsCount: course.studentsCount,
                                rating: course.rating,
                                onTap: () => _navigateToContent(course),
                              ),
                              // Edit badge on card
                              Positioned(
                                top: 22,
                                right: 36,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TeacherShared.primaryBlue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Manage',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
