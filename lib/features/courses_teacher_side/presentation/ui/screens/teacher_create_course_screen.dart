import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/section_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_cubit.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_state.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/widgets/lesson_type_chip.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/widgets/teacher_shared_widgets.dart';
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

  // ── Tab 1 form assets ──────────────────────────────────────────────────────
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

  // ── Publish / Save Action ──────────────────────────────────────────────────

  Future<void> _publish() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
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

    if (widget.existingCourse != null) {
      cubit.updateCourse(course);
    } else {
      await cubit.addCourse(course);

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherCourseCubit, TeacherCourseState>(
      listener: (context, state) {
        if (state is TeacherCourseLoading) {
          setState(() => _isSaving = true);
        } else if (state is TeacherCourseAdded ||
            state is TeacherCourseUpdated) {
          if (widget.existingCourse != null) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course updated!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else if (state is TeacherCourseError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: TeacherShared.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header + Tabs ──────────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: TeacherShared.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(TeacherShared.radiusXXL),
                    bottomRight: Radius.circular(TeacherShared.radiusXXL),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
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
                          color: Colors.white.withAlpha(51), // 20% Alpha
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              TeacherShared.radiusXXXL,
                            ),
                          ),
                          labelColor: TeacherShared.primaryBlue,
                          unselectedLabelColor: Colors.white,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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

              // ── Tab Views (Both with KeepAlive applied) ───────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _CourseInfoTab(
                      formKey: _formKey,
                      titleCtrl: _titleCtrl,
                      instructorCtrl: _instructorCtrl,
                      imageCtrl: _imageCtrl,
                      descCtrl: _descCtrl,
                      tabController: _tabController,
                      fieldDecorationBuilder: teacherInputDecoration,
                    ),
                    _CourseContentTab(
                      sections: _sections,
                      isSaving: _isSaving,
                      existingCourse: widget.existingCourse,
                      onPublish: _publish,
                      fieldDecorationBuilder: teacherInputDecoration,
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
}

// ── Sub-component Tab 1: Course Info ──────────────────────────────────────────

class _CourseInfoTab extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController instructorCtrl;
  final TextEditingController imageCtrl;
  final TextEditingController descCtrl;
  final TabController tabController;
  final InputDecoration Function(String, {String? hint}) fieldDecorationBuilder;

  const _CourseInfoTab({
    required this.formKey,
    required this.titleCtrl,
    required this.instructorCtrl,
    required this.imageCtrl,
    required this.descCtrl,
    required this.tabController,
    required this.fieldDecorationBuilder,
  });

  @override
  State<_CourseInfoTab> createState() => _CourseInfoTabState();
}

class _CourseInfoTabState extends State<_CourseInfoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Course Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.titleCtrl,
              decoration: widget.fieldDecorationBuilder(
                'Course Title',
                hint: 'e.g., Introduction to Web Development',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _label('Instructor Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.instructorCtrl,
              decoration: widget.fieldDecorationBuilder('Instructor Name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _label('Cover Image URL'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.imageCtrl,
              decoration: widget.fieldDecorationBuilder(
                'Image URL',
                hint: 'https://...',
              ),
            ),
            const SizedBox(height: 20),
            _label('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.descCtrl,
              maxLines: 4,
              decoration: widget.fieldDecorationBuilder(
                'Description',
                hint: 'Describe what students will learn.',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.formKey.currentState!.validate()) {
                    widget.tabController.animateTo(1);
                  }
                },
                style: teacherPrimaryButtonStyle(),
                child: const Text(
                  'Next: Add Content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-component Tab 2: Course Content ───────────────────────────────────────

class _CourseContentTab extends StatefulWidget {
  final List<_PendingSection> sections;
  final bool isSaving;
  final CourseModel? existingCourse;
  final VoidCallback onPublish;
  final InputDecoration Function(String, {String? hint}) fieldDecorationBuilder;

  const _CourseContentTab({
    required this.sections,
    required this.isSaving,
    required this.existingCourse,
    required this.onPublish,
    required this.fieldDecorationBuilder,
  });

  @override
  State<_CourseContentTab> createState() => _CourseContentTabState();
}

class _CourseContentTabState extends State<_CourseContentTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _addSection() {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Section',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: widget.fieldDecorationBuilder(
                'Section Title',
                hint: 'e.g., Introduction',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              decoration: widget.fieldDecorationBuilder(
                'Duration',
                hint: 'e.g., 2 Hours',
              ),
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
                widget.sections.add(
                  _PendingSection(
                    id: const Uuid().v4(),
                    title: titleCtrl.text.trim(),
                    duration: durationCtrl.text.trim(),
                    order: widget.sections.length + 1,
                    lessons: [],
                  ),
                );
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4A90D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToAddLesson(_PendingSection section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PendingLessonScreen(
          onLessonAdded: (lesson) {
            setState(() {
              section.lessons.add(lesson);
            });
          },
          fieldDecorationBuilder: widget.fieldDecorationBuilder,
        ),
      ),
    );
  }

  void _navigateToEditLesson(_PendingSection section, _PendingLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PendingLessonScreen(
          existingLesson: lesson,
          onLessonUpdated: (updatedLesson) {
            setState(() {
              final index = section.lessons.indexWhere(
                (l) => l.id == lesson.id,
              );
              if (index != -1) {
                section.lessons[index] = updatedLesson;
              }
            });
          },
          fieldDecorationBuilder: widget.fieldDecorationBuilder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            children: [
              _OutlineButton(
                icon: Icons.add,
                label: '+ Add Section',
                onTap: _addSection,
              ),
              const SizedBox(height: 16),
              if (widget.sections.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      'Add at least one section to publish.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ...widget.sections.map(
                  (ps) => _PendingSectionCard(
                    ps: ps,
                    onDelete: () => setState(() => widget.sections.remove(ps)),
                    onAddLesson: () => _navigateToAddLesson(ps),
                    onDeleteLesson: (pl) =>
                        setState(() => ps.lessons.remove(pl)),
                    onEditLesson: (pl) => _navigateToEditLesson(ps, pl),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: widget.isSaving ? null : widget.onPublish,
                  icon: widget.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.white,
                        ),
                  label: Text(
                    widget.isSaving
                        ? 'Publishing...'
                        : widget.existingCourse != null
                        ? 'Save Changes'
                        : 'Publish Course',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: teacherPrimaryButtonStyle(isDisabled: widget.isSaving),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Extra Helper UI widgets ──────────────────────────────────────────────────

class _PendingSectionCard extends StatelessWidget {
  final _PendingSection ps;
  final VoidCallback onDelete;
  final VoidCallback onAddLesson;
  final void Function(_PendingLesson) onDeleteLesson;
  final void Function(_PendingLesson) onEditLesson;

  const _PendingSectionCard({
    required this.ps,
    required this.onDelete,
    required this.onAddLesson,
    required this.onDeleteLesson,
    required this.onEditLesson,
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
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ps.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: TeacherShared.errorColor,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          if (ps.lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'No lectures yet.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            )
          else
            ...ps.lessons.map(
              (pl) => ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: TeacherShared.primaryBlue,
                ),
                title: Text(
                  pl.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: TeacherShared.primaryBlue,
                        size: 20,
                      ),
                      onPressed: () => onEditLesson(pl),
                      tooltip: 'Edit Lesson',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: TeacherShared.errorColor,
                        size: 20,
                      ),
                      onPressed: () => onDeleteLesson(pl),
                      tooltip: 'Delete Lesson',
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Wrap(
              spacing: 8,
              children: [
                LessonTypeChip(
                  icon: Icons.play_circle_outline,
                  label: 'Add Lecture',
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

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(TeacherShared.radiusLarge),
          border: Border.all(color: TeacherShared.primaryBlue, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: TeacherShared.primaryBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff4A90D9),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pending Lesson Screen (for course creation flow) ────────────────────────

class _PendingLessonScreen extends StatefulWidget {
  final _PendingLesson? existingLesson;
  final void Function(_PendingLesson)? onLessonAdded;
  final void Function(_PendingLesson)? onLessonUpdated;
  final InputDecoration Function(String, {String? hint}) fieldDecorationBuilder;

  const _PendingLessonScreen({
    this.existingLesson,
    this.onLessonAdded,
    this.onLessonUpdated,
    required this.fieldDecorationBuilder,
  });

  @override
  State<_PendingLessonScreen> createState() => _PendingLessonScreenState();
}

class _PendingLessonScreenState extends State<_PendingLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  final _pdfUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingLesson != null) {
      _titleCtrl.text = widget.existingLesson!.title;
      _descCtrl.text = widget.existingLesson!.description;
      _durationCtrl.text = widget.existingLesson!.duration;
      _videoUrlCtrl.text = widget.existingLesson!.videoUrl;
      _pdfUrlCtrl.text = widget.existingLesson!.pdfUrl;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _videoUrlCtrl.dispose();
    _pdfUrlCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final lesson = _PendingLesson(
      id: widget.existingLesson?.id ?? const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      duration: _durationCtrl.text.trim(),
      videoUrl: _videoUrlCtrl.text.trim(),
      pdfUrl: _pdfUrlCtrl.text.trim(),
    );

    if (widget.existingLesson != null) {
      widget.onLessonUpdated?.call(lesson);
    } else {
      widget.onLessonAdded?.call(lesson);
    }
    Navigator.pop(context);
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: TeacherShared.primaryBlue,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherShared.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 18),
              decoration: const BoxDecoration(
                color: TeacherShared.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(TeacherShared.radiusXXL),
                  bottomRight: Radius.circular(TeacherShared.radiusXXL),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.existingLesson != null
                        ? 'Edit Video Lecture'
                        : 'Add Video Lecture',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Card
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('Lecture Details'),
                            TextFormField(
                              controller: _titleCtrl,
                              decoration: widget.fieldDecorationBuilder(
                                'Lecture Title',
                                hint: 'New Lecture',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Title is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descCtrl,
                              maxLines: 3,
                              decoration: widget.fieldDecorationBuilder(
                                'Description',
                                hint:
                                    'What will students learn in this lecture?',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _durationCtrl,
                              decoration: widget.fieldDecorationBuilder(
                                'Duration',
                                hint: 'e.g., 15:30',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Duration is required'
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Format: MM:SS (e.g., 15:30 for 15 minutes 30 seconds)',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Video URL Card
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('Video File'),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: TeacherShared.lightBlue,
                                borderRadius: BorderRadius.circular(
                                  TeacherShared.radiusMedium,
                                ),
                                border: Border.all(
                                  color: TeacherShared.primaryBlue.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.upload_outlined,
                                    color: TeacherShared.primaryBlue,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Enter video URL below',
                                    style: TextStyle(
                                      color: TeacherShared.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'MP4, WebM, or YouTube URL',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _videoUrlCtrl,
                              decoration: widget.fieldDecorationBuilder(
                                'Video URL',
                                hint: 'https://...',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // PDF URL Card
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('Document (Optional)'),
                            TextFormField(
                              controller: _pdfUrlCtrl,
                              decoration: widget.fieldDecorationBuilder(
                                'PDF / Document URL',
                                hint: 'https://...',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(
                            Icons.save_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            widget.existingLesson != null
                                ? 'Update Lesson'
                                : 'Save Lesson',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: teacherPrimaryButtonStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
