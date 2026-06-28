import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/courses_student_side/data/data_sources/courses_remote_data_source.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/repositories/course_repository_impl.dart';
import 'package:learning_management_system/features/courses_student_side/domain/use_cases/get_sections_use_case.dart';
import 'package:learning_management_system/features/courses_student_side/domain/use_cases/get_lessons_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_cubit.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_state.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/screens/teacher_add_lesson_screen.dart';
import 'package:uuid/uuid.dart';

/// Shows all sections + lessons for a course and lets the teacher
/// add/delete sections and lessons.
class TeacherCourseContentScreen extends StatefulWidget {
  final CourseModel course;

  const TeacherCourseContentScreen({super.key, required this.course});

  @override
  State<TeacherCourseContentScreen> createState() =>
      _TeacherCourseContentScreenState();
}

class _TeacherCourseContentScreenState
    extends State<TeacherCourseContentScreen> {
  // local state: sections with their lessons
  final Map<SectionModel, List<LessonModel>> _content = {};
  bool _isLoading = true;
  String? _error;

  late final GetSectionsUseCase _getSectionsUseCase;
  late final GetLessonsUseCase _getLessonsUseCase;

  @override
  void initState() {
    super.initState();
    final ds = FirebaseCoursesRemoteDataSource(FirebaseFirestore.instance);
    final repo = CourseRepositoryImpl(ds);
    _getSectionsUseCase = GetSectionsUseCase(repo);
    _getLessonsUseCase = GetLessonsUseCase(repo);
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _content.clear();
    });
    try {
      final sections =
          await _getSectionsUseCase.call(widget.course.id);
      for (final section in sections) {
        final lessons =
            await _getLessonsUseCase.call(widget.course.id, section.id);
        _content[section] = lessons;
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Add Section Dialog ───────────────────────────────────────────────────

  void _showAddSectionDialog() {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Section',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: _inputDecoration('Section Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              decoration: _inputDecoration('Duration (e.g. 2 Hours)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final section = SectionModel(
                id: const Uuid().v4(),
                title: titleCtrl.text.trim(),
                duration: durationCtrl.text.trim(),
                order: _content.length + 1,
              );
              context
                  .read<TeacherCourseCubit>()
                  .addSection(widget.course.id, section);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4A90D9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Delete Section Confirmation ──────────────────────────────────────────

  void _confirmDeleteSection(SectionModel section) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Section?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete "${section.title}" and all its lessons?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<TeacherCourseCubit>()
                  .deleteSection(widget.course.id, section.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Delete Lesson Confirmation ───────────────────────────────────────────

  void _confirmDeleteLesson(SectionModel section, LessonModel lesson) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Lesson?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${lesson.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TeacherCourseCubit>().deleteLesson(
                    widget.course.id,
                    section.id,
                    lesson.id,
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffF4F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherCourseCubit, TeacherCourseState>(
      listener: (context, state) {
        if (state is TeacherCourseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else if (state is TeacherSectionAdded ||
            state is TeacherSectionDeleted ||
            state is TeacherLessonAdded ||
            state is TeacherLessonDeleted) {
          _fetchContent(); // refresh list from Firestore
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F5F7),
        body: SafeArea(
          child: Column(
            children: [
              // ── AppBar ─────────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: const BoxDecoration(
                  color: Color(0xff4A90D9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ───────────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 48),
                                const SizedBox(height: 12),
                                Text(_error!,
                                    textAlign: TextAlign.center,
                                    style:
                                        const TextStyle(color: Colors.red)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _fetchContent,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchContent,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              children: [
                                // Add Section button
                                _AddSectionButton(
                                    onTap: _showAddSectionDialog),
                                const SizedBox(height: 16),

                                if (_content.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: Column(
                                        children: [
                                          Icon(Icons.playlist_add,
                                              size: 64,
                                              color: Colors.grey.shade300),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No sections yet.\nTap above to add your first section.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ..._content.entries.map((entry) {
                                    final section = entry.key;
                                    final lessons = entry.value;
                                    return _SectionCard(
                                      section: section,
                                      lessons: lessons,
                                      course: widget.course,
                                      onDeleteSection: () =>
                                          _confirmDeleteSection(section),
                                      onDeleteLesson: (lesson) =>
                                          _confirmDeleteLesson(section, lesson),
                                      onAddLesson: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: context
                                                  .read<TeacherCourseCubit>(),
                                              child: TeacherAddLessonScreen(
                                                courseId: widget.course.id,
                                                sectionId: section.id,
                                              ),
                                            ),
                                          ),
                                        ).then((_) => _fetchContent());
                                      },
                                    );
                                  }),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable Sub-Widgets ─────────────────────────────────────────────────────

class _AddSectionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSectionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xff4A90D9), width: 1.5,
              style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xff4A90D9)),
            SizedBox(width: 8),
            Text(
              'Add Section',
              style: TextStyle(
                  color: Color(0xff4A90D9),
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final SectionModel section;
  final List<LessonModel> lessons;
  final CourseModel course;
  final VoidCallback onDeleteSection;
  final VoidCallback onAddLesson;
  final void Function(LessonModel) onDeleteLesson;

  const _SectionCard({
    required this.section,
    required this.lessons,
    required this.course,
    required this.onDeleteSection,
    required this.onAddLesson,
    required this.onDeleteLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                const Icon(Icons.drag_indicator,
                    color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  onPressed: onDeleteSection,
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // Lessons list
          if (lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'No lessons yet. Add one below.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lessons.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 56, endIndent: 16),
              itemBuilder: (_, index) {
                final lesson = lessons[index];
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xffEDF4FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.play_circle_fill,
                        color: Color(0xff4A90D9), size: 20),
                  ),
                  title: Text(lesson.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: lesson.duration.isNotEmpty
                      ? Text(lesson.duration,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12))
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 20),
                    onPressed: () => onDeleteLesson(lesson),
                  ),
                );
              },
            ),

          // Add lesson buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              children: [
                _AddLessonChip(
                  icon: Icons.play_circle_outline,
                  label: 'Video',
                  onTap: onAddLesson,
                ),
                const SizedBox(width: 8),
                _AddLessonChip(
                  icon: Icons.description_outlined,
                  label: 'Document',
                  onTap: onAddLesson,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddLessonChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddLessonChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xffEDF4FD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xff4A90D9).withOpacity(0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xff4A90D9)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xff4A90D9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
