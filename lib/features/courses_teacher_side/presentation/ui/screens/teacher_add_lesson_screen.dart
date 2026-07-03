import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/courses_student_side/data/models/lesson_model.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_cubit.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/cubit/teacher_course_state.dart';
import 'package:learning_management_system/features/courses_teacher_side/presentation/ui/widgets/teacher_shared_widgets.dart';
import 'package:uuid/uuid.dart';

/// Screen for adding a new video/document lesson to a section.
class TeacherAddLessonScreen extends StatefulWidget {
  final String courseId;
  final String sectionId;
  final LessonModel? existingLesson; // null = add, non-null = edit

  const TeacherAddLessonScreen({
    super.key,
    required this.courseId,
    required this.sectionId,
    this.existingLesson,
  });

  @override
  State<TeacherAddLessonScreen> createState() => _TeacherAddLessonScreenState();
}

class _TeacherAddLessonScreenState extends State<TeacherAddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  final _pdfUrlCtrl = TextEditingController();
  bool _isSaving = false;

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

    final lessonId = widget.existingLesson?.id ?? const Uuid().v4();

    final lesson = LessonModel(
      id: lessonId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      duration: _durationCtrl.text.trim(),
      videoUrl: _videoUrlCtrl.text.trim(),
      pdfUrl: _pdfUrlCtrl.text.trim(),
    );

    if (widget.existingLesson != null) {
      context.read<TeacherCourseCubit>().updateLesson(
        widget.courseId,
        widget.sectionId,
        lesson,
      );
    } else {
      context.read<TeacherCourseCubit>().addLesson(
        widget.courseId,
        widget.sectionId,
        lesson,
      );
    }
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
    return BlocListener<TeacherCourseCubit, TeacherCourseState>(
      listener: (context, state) {
        if (state is TeacherCourseLoading) {
          setState(() => _isSaving = true);
        } else if (state is TeacherLessonAdded ||
            state is TeacherLessonUpdated) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is TeacherLessonAdded
                    ? 'Lesson added successfully!'
                    : 'Lesson updated successfully!',
              ),
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
                          ? 'Edit Lesson'
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
                                decoration: teacherInputDecoration(
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
                                decoration: teacherInputDecoration(
                                  'Description',
                                  hint:
                                      'What will students learn in this lecture?',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _durationCtrl,
                                decoration: teacherInputDecoration(
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
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
                                decoration: teacherInputDecoration(
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
                                decoration: teacherInputDecoration(
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
                            onPressed: _isSaving ? null : _submit,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.save_outlined,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isSaving
                                  ? 'Saving...'
                                  : widget.existingLesson != null
                                  ? 'Update Lesson'
                                  : 'Save Lesson',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: teacherPrimaryButtonStyle(
                              isDisabled: _isSaving,
                            ),
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
