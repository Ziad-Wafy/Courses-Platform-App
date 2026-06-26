import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/theme/app_color.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../cubit/quiz_cubit.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../widgets/common_widgets.dart';

class CreateQuizScreen extends StatefulWidget {
  final String courseId;
  final String instructorId;

  const CreateQuizScreen({
    super.key,
    required this.courseId,
    required this.instructorId,
  });

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  late QuizCubit quizCubit;
  final titleController = TextEditingController();
  final timeLimitController = TextEditingController(text: '20');
  final List<QuestionData> questions = [];

  @override
  void initState() {
    super.initState();
    quizCubit = sl<QuizCubit>();
    questions.add(QuestionData());
  }

  @override
  void dispose() {
    titleController.dispose();
    timeLimitController.dispose();
    for (var q in questions) {
      q.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocProvider.value(
        value: quizCubit,
        child: BlocListener<QuizCubit, QuizState>(
          listener: (context, state) {
            if (state is QuizCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz created successfully!')),
              );
              Navigator.pop(context);
            } else if (state is QuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                QuizHeader(
                  title: 'Create Quiz',
                  onBackPressed: () => Navigator.pop(context),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputSection(),
                      SizedBox(height: 24.h),
                      _buildQuestionsSection(),
                      SizedBox(height: 24.h),
                      _buildSaveButton(),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Title',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'New Quiz',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Time Limit (minutes)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: timeLimitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '20',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Questions (${questions.length})',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  questions.add(QuestionData());
                });
              },
              child: Row(
                children: [
                  Icon(Icons.add, size: 20.sp, color: AppColors.primary),
                  SizedBox(width: 4.w),
                  Text(
                    'Add Question',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return _buildQuestionCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = questions[index];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (questions.length > 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      questions.removeAt(index);
                    });
                  },
                  child: Icon(
                    Icons.delete,
                    size: 20.sp,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Question Text',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: question.questionController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your question here...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Answer Options',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question.options.length,
            itemBuilder: (context, optIndex) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          question.correctAnswerIndex = optIndex;
                        });
                      },
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: question.correctAnswerIndex == optIndex
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: question.correctAnswerIndex == optIndex
                            ? Container(
                                margin: EdgeInsets.all(4.w),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: question.options[optIndex],
                        decoration: InputDecoration(
                          hintText: '${String.fromCharCode(65 + optIndex)}. Option ${optIndex + 1}',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
          Text(
            '👆 Click the circle to mark the correct answer',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final isLoading = state is QuizLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Save Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _saveQuiz() {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter quiz title')),
      );
      return;
    }

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }

    // Build quiz questions
    final quizQuestions = <Question>[];
    for (var q in questions) {
      if (q.questionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all questions')),
        );
        return;
      }

      final options = <Answer>[];
      for (int i = 0; i < q.options.length; i++) {
        if (q.options[i].text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all options for Question ${questions.indexOf(q) + 1}')),
          );
          return;
        }
        options.add(
          Answer(
            id: const Uuid().v4(),
            text: q.options[i].text,
          ),
        );
      }

      quizQuestions.add(
        Question(
          id: const Uuid().v4(),
          text: q.questionController.text,
          options: options,
          correctAnswerId: options[q.correctAnswerIndex].id,
          points: 1,
        ),
      );
    }

    final quiz = Quiz(
      id: const Uuid().v4(),
      title: titleController.text,
      courseId: widget.courseId,
      instructorId: widget.instructorId,
      timeLimitMinutes: int.tryParse(timeLimitController.text) ?? 20,
      questions: quizQuestions,
      createdAt: DateTime.now(),
      isLocked: false,
    );

    quizCubit.createQuiz(quiz);
  }
}

class QuestionData {
  final questionController = TextEditingController();
  final List<TextEditingController> options = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int correctAnswerIndex = 0;

  void dispose() {
    questionController.dispose();
    for (var option in options) {
      option.dispose();
    }
  }
}
