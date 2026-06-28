import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_cubit.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_state.dart';
import 'package:uuid/uuid.dart';

// ── Local data classes (only used during creation flow) ───────────────────────

class _PendingLesson {
  String id;
  String title;
  String description;
  String duration;
  String videoUrl;
  String pdfUrl;
  _PendingLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.videoUrl,
    required this.pdfUrl,
  });
}

class _PendingSection {
  String id;
  String title;
  String duration;
  int order;
  List<_PendingLesson> lessons;
  _PendingSection({
    required this.id,
    required this.title,
    required this.duration,
    required this.order,
    required this.lessons,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// Matches Figma: two-tab layout —
///   Tab 1: Course Info (title, instructor, description, image)
///   Tab 2: Course Content (sections + lessons builder + Publish button)
class TeacherCreateCourseScreen extends StatefulWidget {
  /// null = create new course, non-null = edit existing course info only
  final CourseModel? existingCourse;

  const TeacherCreateCourseScreen({super.key, this.existingCourse});

  @override
  State<TeacherCreateCourseScreen> createState() =>
      _TeacherCreateCourseScreenState();
}

class _TeacherCreateCourseScreenState extends State<TeacherCreateCourseScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ── Tab 1 form ────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  // ── Tab 2 content (used only in create mode) ──────────────────────────────
  final List<_PendingSection> _sections = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.existingCourse != null) {
      _titleCtrl.text = widget.existingCourse!.title;
      _instructorCtrl.text = widget.existingCourse!.instructor;
      _descCtrl.text = widget.existingCourse!.description;
      _imageCtrl.text = widget.existingCourse!.image;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _instructorCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  InputDecoration _field(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffF4F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xff4A90D9), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      );

  // ── Section/lesson management (local state) ────────────────────────────────

  void _addSection() {
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
              autofocus: true,
              decoration: _field('Section Title', hint: 'e.g., Introduction'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              decoration: _field('Duration', hint: 'e.g., 2 Hours'),
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
              setState(() {
                _sections.add(_PendingSection(
                  id: const Uuid().v4(),
                  title: titleCtrl.text.trim(),
                  duration: durationCtrl.text.trim(),
                  order: _sections.length + 1,
                  lessons: [],
                ));
              });
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

  void _addLesson(_PendingSection section) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final videoCtrl = TextEditingController();
    final pdfCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Lecture',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: _field('Lecture Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: _field('Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: durationCtrl,
                decoration: _field('Duration', hint: 'e.g. 15:30'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: videoCtrl,
                decoration: _field('Video URL', hint: 'https://...'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pdfCtrl,
                decoration: _field('PDF URL (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                section.lessons.add(_PendingLesson(
                  id: const Uuid().v4(),
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  duration: durationCtrl.text.trim(),
                  videoUrl: videoCtrl.text.trim(),
                  pdfUrl: pdfCtrl.text.trim(),
                ));
              });
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

  // ── Publish / Save ─────────────────────────────────────────────────────────

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    final courseId = widget.existingCourse?.id ?? const Uuid().v4();

    final course = CourseModel(
      id: courseId,
      title: _titleCtrl.text.trim(),
      instructor: _instructorCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      image: _imageCtrl.text.trim(),
      studentsCount: widget.existingCourse?.studentsCount ?? 0,
      rating: widget.existingCourse?.rating ?? 0.0,
    );

    final cubit = context.read<TeacherCourseCubit>();

    // Save course document
    if (widget.existingCourse != null) {
      cubit.updateCourse(course);
    } else {
      // Save course + sections + lessons atomically via cubit
      // We handle ordering here
      await cubit.addCourse(course);

      // Wait for course to be saved before adding nested data
      for (final ps in _sections) {
        final section = SectionModel(
          id: ps.id,
          title: ps.title,
          duration: ps.duration,
          order: ps.order,
        );
        await cubit.addSection(courseId, section);

        for (final pl in ps.lessons) {
          final lesson = LessonModel(
            id: pl.id,
            title: pl.title,
            description: pl.description,
            duration: pl.duration,
            videoUrl: pl.videoUrl,
            pdfUrl: pl.pdfUrl,
          );
          await cubit.addLesson(courseId, ps.id, lesson);
        }
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherCourseCubit, TeacherCourseState>(
      listener: (context, state) {
        if (state is TeacherCourseLoading) {
          setState(() => _isSaving = true);
        } else if (state is TeacherCourseAdded ||
            state is TeacherCourseUpdated) {
          // Only navigate back after the top-level course is confirmed.
          // Sections/lessons will be added sequentially from _publish().
          if (widget.existingCourse != null) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Course updated!'),
              backgroundColor: Colors.green,
            ));
            Navigator.pop(context);
          }
        } else if (state is TeacherCourseError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.redAccent,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F5F7),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header + Tabs ───────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xff4A90D9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            widget.existingCourse != null
                                ? 'Edit Course'
                                : 'Create New Course',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelColor: const Color(0xff4A90D9),
                          unselectedLabelColor: Colors.white,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: 'Course Info'),
                            Tab(text: 'Course Content'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab views ───────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Tab 1: Course Info ────────────────────────────────
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Course Title'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleCtrl,
                              decoration: _field('Course Title',
                                  hint:
                                      'e.g., Introduction to Web Development'),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _label('Instructor Name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _instructorCtrl,
                              decoration: _field('Instructor Name'),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _label('Cover Image URL'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _imageCtrl,
                              decoration:
                                  _field('Image URL', hint: 'https://...'),
                            ),
                            const SizedBox(height: 20),
                            _label('Description'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descCtrl,
                              maxLines: 4,
                              decoration: _field('Description',
                                  hint:
                                      'Describe what students will learn.'),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _tabController.animateTo(1);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff4A90D9),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: const Text(
                                  'Next: Add Content',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Tab 2: Course Content ─────────────────────────────
                    Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            children: [
                              // Add Section button
                              _OutlineButton(
                                icon: Icons.add,
                                label: '+ Add Section',
                                onTap: _addSection,
                              ),
                              const SizedBox(height: 16),

                              if (_sections.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 32),
                                  child: Center(
                                    child: Text(
                                      'Add at least one section to publish.',
                                      style: TextStyle(
                                          color: Colors.grey.shade500),
                                    ),
                                  ),
                                )
                              else
                                ..._sections.map((ps) => _PendingSectionCard(
                                      ps: ps,
                                      onDelete: () =>
                                          setState(() => _sections.remove(ps)),
                                      onAddLesson: () => _addLesson(ps),
                                      onDeleteLesson: (pl) =>
                                          setState(() => ps.lessons.remove(pl)),
                                    )),
                            ],
                          ),
                        ),

                        // Publish + Save Draft buttons
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _publish,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(
                                          Icons.cloud_upload_outlined,
                                          color: Colors.white),
                                  label: Text(
                                    _isSaving
                                        ? 'Publishing...'
                                        : widget.existingCourse != null
                                            ? 'Save Changes'
                                            : 'Publish Course',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff4A90D9),
                                    disabledBackgroundColor:
                                        const Color(0xff4A90D9)
                                            .withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  child: const Text('Save as Draft',
                                      style: TextStyle(fontSize: 15)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
}

// ── Pending section card (used only in create flow) ───────────────────────────

class _PendingSectionCard extends StatelessWidget {
  final _PendingSection ps;
  final VoidCallback onDelete;
  final VoidCallback onAddLesson;
  final void Function(_PendingLesson) onDeleteLesson;

  const _PendingSectionCard({
    required this.ps,
    required this.onDelete,
    required this.onAddLesson,
    required this.onDeleteLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Section title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(ps.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Lessons
          if (ps.lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('No lectures yet.',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 13)),
            )
          else
            ...ps.lessons.map((pl) => ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: Color(0xff4A90D9)),
                  title: Text(pl.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 20),
                    onPressed: () => onDeleteLesson(pl),
                  ),
                )),

          // Add lesson chips (matching Figma: Video | Document | Quiz)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Wrap(
              spacing: 8,
              children: [
                _LessonTypeChip(
                    icon: Icons.play_circle_outline,
                    label: 'Video',
                    onTap: onAddLesson),
                _LessonTypeChip(
                    icon: Icons.description_outlined,
                    label: 'Document',
                    onTap: onAddLesson),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LessonTypeChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xffEDF4FD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xff4A90D9).withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xff4A90D9)),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Color(0xff4A90D9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff4A90D9), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xff4A90D9)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Color(0xff4A90D9),
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

