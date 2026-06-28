import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/course_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_cubit.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_state.dart';
import 'package:uuid/uuid.dart';

/// Two-tab screen: Course Info + Course Content (section/lesson builder)
class TeacherCreateCourseScreen extends StatefulWidget {
  final CourseModel? existingCourse; // null = create mode, non-null = edit mode

  const TeacherCreateCourseScreen({super.key, this.existingCourse});

  @override
  State<TeacherCreateCourseScreen> createState() =>
      _TeacherCreateCourseScreenState();
}

class _TeacherCreateCourseScreenState
    extends State<TeacherCreateCourseScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _titleCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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

  void _saveInfo() {
    if (!_formKey.currentState!.validate()) return;
    _tabController.animateTo(1); // Move to Content tab
  }

  void _publishCourse() {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    final courseId =
        widget.existingCourse?.id ?? const Uuid().v4();

    final course = CourseModel(
      id: courseId,
      title: _titleCtrl.text.trim(),
      instructor: _instructorCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      image: _imageCtrl.text.trim(),
      studentsCount: widget.existingCourse?.studentsCount ?? 0,
      rating: widget.existingCourse?.rating ?? 0.0,
    );

    if (widget.existingCourse != null) {
      context.read<TeacherCourseCubit>().updateCourse(course);
    } else {
      context.read<TeacherCourseCubit>().addCourse(course);
    }
  }

  InputDecoration _inputDecoration(String label, {String? hint}) =>
      InputDecoration(
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherCourseCubit, TeacherCourseState>(
      listener: (context, state) {
        if (state is TeacherCourseLoading) {
          setState(() => _isSaving = true);
        } else if (state is TeacherCourseAdded ||
            state is TeacherCourseUpdated) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state is TeacherCourseAdded
                  ? 'Course created successfully!'
                  : 'Course updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
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
              // ── Header ─────────────────────────────────────────────────
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
                    // Back + Title
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
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
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
                            Tab(text: 'Save & Publish'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Views ──────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1 – Course Info Form
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Course Title',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleCtrl,
                              decoration: _inputDecoration('Course Title',
                                  hint: 'e.g., Introduction to Web Development'),
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Title is required'
                                      : null,
                            ),
                            const SizedBox(height: 20),
                            const Text('Instructor Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _instructorCtrl,
                              decoration:
                                  _inputDecoration('Instructor Name'),
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Instructor is required'
                                      : null,
                            ),
                            const SizedBox(height: 20),
                            const Text('Cover Image URL',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _imageCtrl,
                              decoration: _inputDecoration('Image URL',
                                  hint: 'https://...'),
                            ),
                            const SizedBox(height: 20),
                            const Text('Description',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descCtrl,
                              maxLines: 4,
                              decoration: _inputDecoration('Description',
                                  hint:
                                      'Describe what students will learn in this course.'),
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Description is required'
                                      : null,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _saveInfo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff4A90D9),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: const Text(
                                  'Next: Save & Publish',
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

                    // Tab 2 – Publish / Save Draft
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Preview card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Course Preview',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 12),
                                AnimatedBuilder(
                                  animation: Listenable.merge([
                                    _titleCtrl,
                                    _instructorCtrl,
                                    _descCtrl
                                  ]),
                                  builder: (_, __) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _titleCtrl.text.isEmpty
                                            ? 'Your Course Title'
                                            : _titleCtrl.text,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _instructorCtrl.text.isEmpty
                                            ? 'Instructor Name'
                                            : _instructorCtrl.text,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _descCtrl.text.isEmpty
                                            ? 'Your course description will appear here.'
                                            : _descCtrl.text,
                                        style: const TextStyle(
                                            fontSize: 13, height: 1.5),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Publish button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _publishCourse,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.cloud_upload_outlined,
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
                                    const Color(0xff4A90D9).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.grey.shade300, width: 1.5),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
