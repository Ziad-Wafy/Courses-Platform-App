import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import 'package:learning_management_system/core/theme/app_color.dart';
import 'package:learning_management_system/core/utils/service_locator.dart';
import 'package:learning_management_system/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:learning_management_system/features/quiz/domain/entities/quiz_entity.dart';

class CreateQuizScreen extends StatefulWidget {
  final String courseId;
  final String instructorId;
  const CreateQuizScreen({super.key, required this.courseId, required this.instructorId});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final titleController = TextEditingController();
  final timeController = TextEditingController(text: '20');
  final List<QuestionData> questions = [QuestionData()];
  late QuizCubit quizCubit;

  @override
  void initState() {
    super.initState();
    quizCubit = sl<QuizCubit>();
  }

  void _save() {
    final title = titleController.text.trim();
    if (title.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
       return;
    }
    
    final quizQuestions = questions.map((q) {
      final options = q.optionControllers.map((oc) => Answer(id: const Uuid().v4(), text: oc.text)).toList();
      return Question(
        id: const Uuid().v4(),
        text: q.questionController.text,
        options: options,
        correctAnswerId: options[q.correctIndex].id,
      );
    }).toList();

    final quiz = Quiz(
      id: const Uuid().v4(),
      title: title,
      courseId: widget.courseId,
      instructorId: widget.instructorId,
      timeLimitMinutes: int.tryParse(timeController.text) ?? 20,
      questions: quizQuestions,
      createdAt: DateTime.now(),
    );
    quizCubit.createQuiz(quiz);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: quizCubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Quiz'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: BlocListener<QuizCubit, QuizState>(
          listener: (context, state) {
            if (state is QuizCreated) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz Saved!')));
            }
            if (state is QuizError) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Quiz Title')),
                TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time Limit (Min)'), keyboardType: TextInputType.number),
                SizedBox(height: 24.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (context, i) => _buildQuestionCard(i),
                ),
                ElevatedButton(onPressed: () => setState(() => questions.add(QuestionData())), child: const Text('Add Question')),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 50.h)),
                  child: const Text('Save Quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int i) {
    final q = questions[i];
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            TextField(controller: q.questionController, decoration: InputDecoration(labelText: 'Question ${i + 1}')),
            ...List.generate(4, (oi) => Row(children: [
              Radio<int>(value: oi, groupValue: q.correctIndex, onChanged: (v) => setState(() => q.correctIndex = v!)),
              Expanded(child: TextField(controller: q.optionControllers[oi], decoration: InputDecoration(labelText: 'Option ${oi + 1}'))),
            ])),
          ],
        ),
      ),
    );
  }
}

class QuestionData {
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(4, (_) => TextEditingController());
  int correctIndex = 0;
}
