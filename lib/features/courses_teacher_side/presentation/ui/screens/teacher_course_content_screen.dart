import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/courses_student_side/data/data_sources/courses_remote_data_source.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/repositories/course_repository_impl.dart';
import 'package:learning_management_system/features/courses_student_side/domain/use_cases/get_lessons_use_case.dart';
import 'package:learning_management_system/features/courses_student_side/domain/use_cases/get_sections_use_case.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_cubit.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_state.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/screens/teacher_add_lesson_screen.dart';
import 'package:uuid/uuid.dart';

// ── Data type ────────────────────────────────────────────────────────────────

/// Holds a section together with its ordered lessons.
class _SectionEntry {
  final SectionModel section;
  final List<LessonModel> lessons;
  _SectionEntry({required this.section, required this.lessons});
}

// ── Screen ───────────────────────────────────────────────────────────────────

/// Shows all sections + lessons for a course and lets the teacher
/// add/delete/edit sections and lessons.
class TeacherCourseContentScreen extends StatefulWidget {
  final CourseModel course;
  const TeacherCourseContentScreen({super.key, required this.course});

  @override
  State<TeacherCourseContentScreen> createState() =>
      _TeacherCourseContentScreenState();
}

class _TeacherCourseContentScreenState
    extends State<TeacherCourseContentScreen> {
  /// Using a List<_SectionEntry> so SectionModel is never used as a Map key
  /// (SectionModel has no == / hashCode overrides).
  List<_SectionEntry> _entries = [];
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

  // ── Data fetching ────────────────────────────────────────────────────────

  Future<void> _fetchContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _entries = [];
    });
    try {
      final sections = await _getSectionsUseCase.call(widget.course.id);
      final entries = <_SectionEntry>[];
      for (final section in sections) {
        final lessons = await _getLessonsUseCase.call(
          widget.course.id,
          section.id,
        );
        entries.add(_SectionEntry(section: section, lessons: lessons));
      }
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Section dialogs ──────────────────────────────────────────────────────

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
                order: _entries.length + 1,
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

  void _showEditSectionDialog(SectionModel section) {
    final titleCtrl = TextEditingController(text: section.title);
    final durationCtrl = TextEditingController(text: section.duration);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Section',
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
              decoration: _inputDecoration('Duration'),
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
              final updated = SectionModel(
                id: section.id,
                title: titleCtrl.text.trim(),
                duration: durationCtrl.text.trim(),
                order: section.order,
              );
              context
                  .read<TeacherCourseCubit>()
                  .updateSection(widget.course.id, updated);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4A90D9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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

  // ── Lesson navigation ────────────────────────────────────────────────────

  void _navigateToAddLesson(String sectionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TeacherCourseCubit>(),
          child: TeacherAddLessonScreen(
            courseId: widget.course.id,
            sectionId: sectionId,
          ),
        ),
      ),
    ).then((_) => _fetchContent());
  }

  void _navigateToEditLesson(String sectionId, LessonModel lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TeacherCourseCubit>(),
          child: TeacherAddLessonScreen(
            courseId: widget.course.id,
            sectionId: sectionId,
            existingLesson: lesson,
          ),
        ),
      ),
    ).then((_) => _fetchContent());
  }

  void _confirmDeleteLesson(String sectionId, LessonModel lesson) {
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
              context
                  .read<TeacherCourseCubit>()
                  .deleteLesson(widget.course.id, sectionId, lesson.id);
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

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherCourseCubit, TeacherCourseState>(
      listener: (context, state) {
        if (state is TeacherCourseError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.redAccent,
          ));
        } else if (state is TeacherSectionAdded ||
            state is TeacherSectionUpdated ||
            state is TeacherSectionDeleted ||
            state is TeacherLessonAdded ||
            state is TeacherLessonUpdated ||
            state is TeacherLessonDeleted) {
          _fetchContent();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F5F7),
        body: SafeArea(
          child: Column(
            children: [
              // ── AppBar ───────────────────────────────────────────────
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

              // ── Body ─────────────────────────────────────────────────
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
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              children: [
                                _AddSectionButton(
                                    onTap: _showAddSectionDialog),
                                const SizedBox(height: 16),
                                if (_entries.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(top: 40),
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
                                  ..._entries.map((entry) => _SectionCard(
                                        entry: entry,
                                        onEditSection: () =>
                                            _showEditSectionDialog(
                                                entry.section),
                                        onDeleteSection: () =>
                                            _confirmDeleteSection(
                                                entry.section),
                                        onAddLesson: () =>
                                            _navigateToAddLesson(
                                                entry.section.id),
                                        onEditLesson: (lesson) =>
                                            _navigateToEditLesson(
                                                entry.section.id, lesson),
                                        onDeleteLesson: (lesson) =>
                                            _confirmDeleteLesson(
                                                entry.section.id, lesson),
                                      )),
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

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

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
              color: const Color(0xff4A90D9),
              width: 1.5,
              style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
  final _SectionEntry entry;
  final VoidCallback onEditSection;
  final VoidCallback onDeleteSection;
  final VoidCallback onAddLesson;
  final void Function(LessonModel) onEditLesson;
  final void Function(LessonModel) onDeleteLesson;

  const _SectionCard({
    required this.entry,
    required this.onEditSection,
    required this.onDeleteSection,
    required this.onAddLesson,
    required this.onEditLesson,
    required this.onDeleteLesson,
  });

  @override
  Widget build(BuildContext context) {
    final section = entry.section;
    final lessons = entry.lessons;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (section.duration.isNotEmpty)
                        Text(section.duration,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                // Edit section
                IconButton(
                  icon:
                      const Icon(Icons.edit_outlined, color: Color(0xff4A90D9)),
                  onPressed: onEditSection,
                  tooltip: 'Edit Section',
                ),
                // Delete section
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: onDeleteSection,
                  tooltip: 'Delete Section',
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // Lessons
          if (lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'No lessons yet.',
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
              itemBuilder: (_, i) {
                final lesson = lessons[i];
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: Color(0xff4A90D9), size: 20),
                        onPressed: () => onEditLesson(lesson),
                        tooltip: 'Edit Lesson',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        onPressed: () => onDeleteLesson(lesson),
                        tooltip: 'Delete Lesson',
                      ),
                    ],
                  ),
                );
              },
            ),

          // Add lesson button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: GestureDetector(
              onTap: onAddLesson,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xffEDF4FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xff4A90D9).withValues(alpha: 0.4),
                      width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Color(0xff4A90D9)),
                    SizedBox(width: 6),
                    Text('Add Lecture',
                        style: TextStyle(
                            color: Color(0xff4A90D9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

