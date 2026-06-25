# 🎯 Quiz Feature Implementation Guide

## **Overview**
Complete quiz system with clean architecture following SOLID principles. Includes quiz creation, taking quizzes, and viewing results.

---

## **📁 Project Structure**

```
lib/features/quiz/
├── data/
│   ├── models/
│   │   └── quiz_model.dart           # Firebase data models
│   └── repositories/
│       └── quiz_repository_impl.dart # Firebase implementation
├── domain/
│   ├── entities/
│   │   └── quiz_entity.dart          # Domain models
│   ├── repositories/
│   │   └── quiz_repository.dart      # Repository interface
│   └── usecases/
│       └── quiz_usecases.dart        # Business logic
├── presentation/
│   ├── cubit/
│   │   └── quiz_cubit.dart           # State management
│   ├── routes/
│   │   └── quiz_routes.dart          # Navigation
│   └── ui/
│       ├── screens/
│       │   ├── quizzes_assessments_screen.dart
│       │   ├── quiz_question_screen.dart
│       │   ├── quiz_completion_screen.dart
│       │   └── create_quiz_screen.dart
│       └── widgets/
│           └── common_widgets.dart
```

---

## **🔧 How to Integrate into Your Main App**

### **Step 1: Update pubspec.yaml**
Make sure you have these dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.0.0
  get_it: ^7.0.0
  firebase_core: ^24.0.0
  cloud_firestore: ^4.0.0
  flutter_screenutil: ^5.0.0
  uuid: ^3.0.0
  equatable: ^2.0.0
```

Run: `flutter pub get`

### **Step 2: Update Main App Routes**
Add quiz routes to your MaterialApp or GoRouter:

```dart
// Option 1: Using MaterialApp with routes
MaterialApp(
  routes: {
    ...QuizRoutes.getRoutes(),  // Add this
    // Other routes...
  },
  // ...
)

// Option 2: Using named navigation
Navigator.pushNamed(context, '/quiz/list', arguments: courseId);
```

### **Step 3: Verify Firebase Setup**
- Quiz data is stored in Firestore collections:
  - `quizzes` - All quiz data
  - `quiz_results` - Student results
- No additional setup needed if Firebase is already configured

---

## **🎮 How to Use Each Screen**

### **1. Quizzes & Assessments Screen**
**Location:** `/quiz/list`
**Arguments:** courseId (String)

Shows all quizzes for a course with:
- Average score display
- Quiz list with question count and time limit
- Start Quiz button for unlocked quizzes
- View Results and Retake buttons for completed quizzes

```dart
// Navigate to quizzes list
Navigator.pushNamed(
  context,
  '/quiz/list',
  arguments: 'course_123',
);
```

### **2. Quiz Question Screen**
**Location:** `/quiz/question`
**Arguments:** quizId (String)

Features:
- Timer countdown (configurable per quiz)
- Progress bar showing current question
- Multiple choice options (radio button style)
- Previous/Next navigation
- Auto-submit on timer expiry

```dart
// Navigate to quiz question screen
Navigator.pushNamed(
  context,
  '/quiz/question',
  arguments: 'quiz_123',
);
```

### **3. Quiz Completion Screen**
**Location:** `/quiz/completion`
**Arguments:** Map with keys:
- `correctAnswers` (int)
- `totalQuestions` (int)
- `scorePercentage` (double)
- `quizId` (String)
- `courseId` (String)

Shows:
- Congratulations message (if passed)
- Score display and breakdown
- Correct/Incorrect count cards
- Retake Quiz button
- Back to Quizzes button

```dart
// Navigate after quiz completion
Navigator.pushNamed(
  context,
  '/quiz/completion',
  arguments: {
    'correctAnswers': 18,
    'totalQuestions': 20,
    'scorePercentage': 90.0,
    'quizId': 'quiz_123',
    'courseId': 'course_123',
  },
);
```

### **4. Create Quiz Screen**
**Location:** `/quiz/create`
**Arguments:** Map with keys:
- `courseId` (String)
- `instructorId` (String)

Instructors can:
- Set quiz title and time limit
- Add multiple questions
- Configure 4 answer options per question
- Mark correct answer
- Save quiz to Firestore

```dart
// Navigate to create quiz
Navigator.pushNamed(
  context,
  '/quiz/create',
  arguments: {
    'courseId': 'course_123',
    'instructorId': 'instructor_123',
  },
);
```

---

## **🎨 Common Widgets Used**

### **QuizHeader**
Used in all screens for consistent header styling.

```dart
QuizHeader(
  title: 'Quiz Title',
  subtitle: 'Optional subtitle',
  onBackPressed: () => Navigator.pop(context),
)
```

### **QuizCard**
Displays individual quiz information in list.

```dart
QuizCard(
  title: 'Introduction Quiz',
  questionsCount: 10,
  timeLimit: 15,
  score: 90.5,
  isLocked: false,
  onStartQuiz: () => Navigator.pushNamed(context, '/quiz/question'),
)
```

### **ProgressBar**
Shows quiz progress and remaining time.

```dart
ProgressBar(
  currentQuestion: 5,
  totalQuestions: 20,
  remainingSeconds: 1245,
)
```

### **ResultCard**
Displays quiz score and breakdown.

```dart
ResultCard(
  correctAnswers: 18,
  totalQuestions: 20,
  scorePercentage: 90.0,
  passed: true,
)
```

---

## **🔄 State Management (Cubit)**

The `QuizCubit` handles all state:

### **States**
- `QuizInitial` - Initial state
- `QuizLoading` - Loading data
- `QuizzesLoaded` - List of quizzes loaded
- `QuizLoaded` - Single quiz loaded
- `QuizCreated` - Quiz successfully created
- `QuizAnswersSubmitted` - Answers submitted
- `QuizResultLoaded` - Result loaded
- `StudentQuizResultsLoaded` - Student's all results loaded
- `QuizError` - Error occurred

### **Methods**
```dart
// Get quizzes for a course
quizCubit.getQuizzesByCourse(courseId);

// Get specific quiz
quizCubit.getQuizById(quizId);

// Create new quiz
quizCubit.createQuiz(quiz);

// Submit answers
quizCubit.submitAnswers(quizId, studentId, answers);

// Get quiz result
quizCubit.getQuizResult(resultId);

// Get student's all results
quizCubit.getStudentResults(studentId);

// Update quiz
quizCubit.updateQuiz(quiz);

// Delete quiz
quizCubit.deleteQuiz(quizId);
```

---

## **📊 Data Models**

### **Quiz Model**
```dart
Quiz {
  id: String,
  title: String,
  courseId: String,
  instructorId: String,
  timeLimitMinutes: int,
  questions: List<Question>,
  createdAt: DateTime,
  isLocked: bool,
}
```

### **Question Model**
```dart
Question {
  id: String,
  text: String,
  options: List<Answer>,
  correctAnswerId: String,
  points: int,
}
```

### **QuizResult Model**
```dart
QuizResult {
  id: String,
  quizId: String,
  studentId: String,
  correctAnswers: int,
  totalQuestions: int,
  scorePercentage: double,
  completedAt: DateTime,
  timeSpentSeconds: int,
  answers: List<StudentAnswer>,
  passed: bool,
}
```

---

## **🗄️ Firestore Collections Structure**

### **quizzes Collection**
```json
{
  "id": "quiz_123",
  "title": "Introduction Quiz",
  "courseId": "course_123",
  "instructorId": "instructor_123",
  "timeLimitMinutes": 20,
  "totalQuestions": 20,
  "isLocked": false,
  "createdAt": "2024-01-15T10:30:00Z",
  "questions": [
    {
      "id": "q1",
      "text": "What is the capital of France?",
      "points": 1,
      "correctAnswerId": "ans1",
      "options": [
        {"id": "ans1", "text": "Paris"},
        {"id": "ans2", "text": "London"},
        {"id": "ans3", "text": "Berlin"},
        {"id": "ans4", "text": "Madrid"}
      ]
    }
  ]
}
```

### **quiz_results Collection**
```json
{
  "id": "result_123",
  "quizId": "quiz_123",
  "studentId": "student_456",
  "correctAnswers": 18,
  "totalQuestions": 20,
  "scorePercentage": 90.0,
  "passed": true,
  "completedAt": "2024-01-15T11:00:00Z",
  "timeSpentSeconds": 900,
  "answers": [
    {
      "questionId": "q1",
      "selectedAnswerId": "ans1",
      "isCorrect": true
    }
  ]
}
```

---

## **🚀 Quick Start Example**

```dart
// In your course details screen, add a button to navigate to quizzes:

ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/quiz/list',
      arguments: courseId,
    );
  },
  child: const Text('View Quizzes'),
)

// Or create a quiz (instructor only):

ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/quiz/create',
      arguments: {
        'courseId': courseId,
        'instructorId': currentUserId,
      },
    );
  },
  child: const Text('Create Quiz'),
)
```

---

## **⚡ Key Features**

✅ **Clean Architecture** - Separated data, domain, and presentation layers
✅ **BLoC/Cubit** - State management
✅ **Firebase Integration** - Firestore backend
✅ **Responsive Design** - Adapts to all screen sizes
✅ **Timer Management** - Auto-submit on timeout
✅ **Answer Validation** - Automatic score calculation
✅ **Result Tracking** - Complete quiz history
✅ **Passing Logic** - Configurable passing score (60%)

---

## **🐛 Troubleshooting**

### **Quiz not loading**
- Check Firestore rules allow reading from `quizzes` collection
- Verify courseId is correct
- Check Firebase initialization

### **Answers not submitting**
- Verify Firestore rules allow writing to `quiz_results`
- Ensure studentId is provided correctly
- Check network connectivity

### **Timer not working**
- Verify timeLimitMinutes is set on quiz
- Check system clock is synchronized
- Look for any background processes interfering

---

## **📝 Notes**

- Passing score is hardcoded to 60%. Modify in `QuizResult.passed` getter to change
- Questions support only multiple choice (4 options)
- Timer starts immediately when quiz loads
- Answers are automatically submitted when timer expires
- All times are stored in seconds in Firestore

---

**Last Updated:** January 2024
**Version:** 1.0.0
