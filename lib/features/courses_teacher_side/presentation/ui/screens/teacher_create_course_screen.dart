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

  // ── Shared Decoration Builder ──────────────────────────────────────────────

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
      borderSide: const BorderSide(color: Color(0xff4A90D9), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  );

  // ── Publish / Save Action ──────────────────────────────────────────────────

  Future<void> _publish() async {
    print("_publish");
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      print("_publish - validation failed or form unmounted");
      _tabController.animateTo(0);
      return;
    }

    print("========================= 1 =========================");
    final courseId = widget.existingCourse?.id ?? const Uuid().v4();
    print("========================= 2 =========================");

    final course = CourseModel(
      id: courseId,
      title: _titleCtrl.text.trim(),
      instructor: _instructorCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      image: _imageCtrl.text.trim(),
      studentsCount: widget.existingCourse?.studentsCount ?? 0,
      rating: widget.existingCourse?.rating ?? 0.0,
    );
    print("========================= 3 =========================");

    final cubit = context.read<TeacherCourseCubit>();
    print("========================= 4 =========================");

    if (widget.existingCourse != null) {
      cubit.updateCourse(course);
      print("========================= 5 =========================");
    } else {
      print("========================= 6 =========================");
      await cubit.addCourse(course);

      for (final ps in _sections) {
        final section = SectionModel(
          id: ps.id,
          title: ps.title,
          duration: ps.duration,
          order: ps.order,
        );
        await cubit.addSection(courseId, section);
        print("========================= 7 =========================");

        for (final pl in ps.lessons) {
          final lesson = LessonModel(
            id: pl.id,
            title: pl.title,
            description: pl.description,
            duration: pl.duration,
            videoUrl: pl.videoUrl,
            pdfUrl: pl.pdfUrl,
          );
          print("========================= 8 =========================");
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
        backgroundColor: const Color(0xffF4F5F7),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header + Tabs ──────────────────────────────────────────────
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
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelColor: const Color(0xff4A90D9),
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
                      fieldDecorationBuilder: _field,
                    ),
                    _CourseContentTab(
                      sections: _sections,
                      isSaving: _isSaving,
                      existingCourse: widget.existingCourse,
                      onPublish: _publish,
                      fieldDecorationBuilder: _field,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4A90D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
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
        title: const Text(
          'Add Lecture',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: widget.fieldDecorationBuilder('Lecture Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: widget.fieldDecorationBuilder('Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: durationCtrl,
                decoration: widget.fieldDecorationBuilder(
                  'Duration',
                  hint: 'e.g. 15:30',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: videoCtrl,
                decoration: widget.fieldDecorationBuilder(
                  'Video URL',
                  hint: 'https://...',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pdfCtrl,
                decoration: widget.fieldDecorationBuilder('PDF URL (optional)'),
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
                section.lessons.add(
                  _PendingLesson(
                    id: const Uuid().v4(),
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    duration: durationCtrl.text.trim(),
                    videoUrl: videoCtrl.text.trim(),
                    pdfUrl: pdfCtrl.text.trim(),
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
                    onAddLesson: () => _addLesson(ps),
                    onDeleteLesson: (pl) =>
                        setState(() => ps.lessons.remove(pl)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4A90D9),
                    disabledBackgroundColor: const Color(
                      0xff4A90D9,
                    ).withAlpha(128),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save as Draft',
                    style: TextStyle(fontSize: 15),
                  ),
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
                    color: Colors.redAccent,
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
                  color: Color(0xff4A90D9),
                ),
                title: Text(
                  pl.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => onDeleteLesson(pl),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Wrap(
              spacing: 8,
              children: [
                _LessonTypeChip(
                  icon: Icons.play_circle_outline,
                  label: 'Video',
                  onTap: onAddLesson,
                ),
                _LessonTypeChip(
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

class _LessonTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LessonTypeChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
            color: const Color(0xff4A90D9).withAlpha(102),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xff4A90D9)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff4A90D9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff4A90D9), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xff4A90D9)),
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
