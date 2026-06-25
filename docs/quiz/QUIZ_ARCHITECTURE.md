# 🏗️ QUIZ FEATURE - ARCHITECTURE DIAGRAM

## **System Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACE LAYER                           │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐  │
│  │  Quiz List      │  │ Quiz Question    │  │ Quiz Completion      │  │
│  │  Screen         │  │ Screen           │  │ Screen               │  │
│  └────────┬─────────┘  └────────┬─────────┘  └─────────┬────────────┘  │
│           │                     │                      │               │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │              Common Widgets (Reusable Components)               │  │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────────────┐    │  │
│  │  │ QuizHeader   │ │ QuizCard     │ │ ProgressBar/ResultCard│    │  │
│  │  └──────────────┘ └──────────────┘ └──────────────────────┘    │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                  │                                      │
│                        ┌─────────▼──────────┐                          │
│                        │   Create Quiz      │                          │
│                        │   Screen           │                          │
│                        └─────────┬──────────┘                          │
└────────────────────────────────────┼───────────────────────────────────┘
                                     │
                    ┌────────────────▼────────────────┐
                    │   STATE MANAGEMENT (BLoC)       │
                    │                                 │
                    │    QuizCubit                    │
                    │  ┌──────────────────────────┐  │
                    │  │ • QuizLoading            │  │
                    │  │ • QuizzesLoaded          │  │
                    │  │ • QuizLoaded             │  │
                    │  │ • QuizAnswersSubmitted   │  │
                    │  │ • QuizResultLoaded       │  │
                    │  │ • QuizError              │  │
                    │  └──────────────────────────┘  │
                    └────────────────┬────────────────┘
                                     │
           ┌─────────────────────────┼─────────────────────────┐
           │                         │                         │
    ┌──────▼──────────┐    ┌─────────▼──────────┐   ┌─────────▼────────┐
    │   USE CASES     │    │   USE CASES        │   │   USE CASES      │
    │                 │    │                    │   │                  │
    │ GetQuizzes      │    │ SubmitQuizAnswers  │   │ GetStudentResults│
    │ GetQuizById     │    │ CreateQuiz         │   │ UpdateQuiz       │
    │ DeleteQuiz      │    │ GetQuizResult      │   │ GetQuizResult    │
    └────────┬────────┘    └────────┬───────────┘   └────────┬─────────┘
             │                      │                         │
             └──────────────────────┼─────────────────────────┘
                                    │
              ┌─────────────────────▼─────────────────────┐
              │      REPOSITORY INTERFACE                 │
              │    (Domain Layer Contract)                │
              │                                           │
              │  QuizRepository (abstract)                │
              └─────────────────────┬─────────────────────┘
                                    │
              ┌─────────────────────▼─────────────────────┐
              │   REPOSITORY IMPLEMENTATION               │
              │   (Data Layer)                            │
              │                                           │
              │  QuizRepositoryImpl                       │
              │  • Model to Entity conversion            │
              │  • Score calculation                     │
              │  • Error handling                        │
              └─────────────────────┬─────────────────────┘
                                    │
              ┌─────────────────────▼─────────────────────┐
              │   DATA LAYER - MODELS                     │
              │                                           │
              │  QuizModel, QuestionModel                │
              │  AnswerModel, QuizResultModel            │
              │  StudentAnswerModel                      │
              │                                           │
              │  (Firebase serialization)                │
              └─────────────────────┬─────────────────────┘
                                    │
              ┌─────────────────────▼─────────────────────┐
              │   EXTERNAL SERVICE - FIREBASE            │
              │                                           │
              │  Firestore Database                      │
              │  ┌──────────────┐  ┌─────────────────┐  │
              │  │ quizzes      │  │ quiz_results    │  │
              │  │ collection   │  │ collection      │  │
              │  └──────────────┘  └─────────────────┘  │
              └─────────────────────────────────────────┘
```

---

## **Data Flow Diagram**

```
START: User clicks "View Quizzes"
       │
       ▼
  Navigator.pushNamed(context, '/quiz/list', arguments: courseId)
       │
       ▼
  QuizzesAndAssessmentsScreen loads
       │
       ▼
  BlocProvider<QuizCubit> wraps the screen
       │
       ▼
  quizCubit.getQuizzesByCourse(courseId)
       │
       ├─► QuizLoading (emit)
       │
       ▼
  GetQuizzesUseCase(repository).call(courseId)
       │
       ▼
  QuizRepository.getQuizzesByCourse(courseId)
       │
       ▼
  QuizRepositoryImpl queries Firestore
       │
       ├─► firebaseFirestore.collection('quizzes')
       │   .where('courseId', isEqualTo: courseId)
       │   .get()
       │
       ▼
  Firestore returns QuerySnapshot
       │
       ▼
  Convert QuizModel → Quiz Entity
       │
       ├─► QuizzesLoaded(quizzes) (emit)
       │
       ▼
  UI rebuilds with quiz list
       │
       ▼
  User sees quizzes and clicks "Start Quiz"
       │
       ▼
  Navigator.pushNamed(context, '/quiz/question', arguments: quizId)
       │
       ▼
  QuizQuestionScreen loads with timer
       │
       ▼
  User answers questions and clicks "Submit"
       │
       ▼
  quizCubit.submitAnswers(quizId, studentId, answers)
       │
       ├─► QuizLoading (emit)
       │
       ▼
  SubmitQuizAnswersUseCase.call(quizId, studentId, answers)
       │
       ▼
  QuizRepositoryImpl processes answers:
       │
       ├─► Calculate correct count
       ├─► Calculate score percentage
       ├─► Create StudentAnswerModels
       ├─► Create QuizResultModel
       │
       ▼
  Save to Firestore quiz_results collection
       │
       ├─► QuizAnswersSubmitted(result) (emit)
       │
       ▼
  Navigator.pushNamed(context, '/quiz/completion', arguments: resultData)
       │
       ▼
  QuizCompletionScreen shows results
       │
       ▼
  User sees score and options:
       │
       ├─► [Retake Quiz] → back to QuizQuestionScreen
       │
       └─► [Back to Quizzes] → back to QuizzesAndAssessmentsScreen
```

---

## **State Diagram - QuizCubit**

```
┌──────────────────┐
│  QuizInitial     │◄─────────────────────────────┐
│  (Starting State)│                              │
└────────┬─────────┘                              │
         │                                        │
         ├─ getQuizzesByCourse()                  │
         ├─ getQuizById()                         │
         ├─ createQuiz()                          │
         └─ getStudentResults()                   │
         │                                        │
         ▼                                        │
    ┌──────────────┐                             │
    │ QuizLoading  │                             │
    └──────┬───────┘                             │
           │                                      │
           ├─ Success ──┐                        │
           │             │                        │
           │      ┌──────┴──────────────────┐    │
           │      │                         │    │
           │      ▼                         ▼    │
           │  ┌─────────────────┐  ┌─────────────────┐
           │  │ QuizzesLoaded   │  │  QuizLoaded     │
           │  │ (List<Quiz>)    │  │  (Quiz)         │
           │  └────────┬────────┘  └────────┬────────┘
           │           │                    │
           │           └──────────┬─────────┘
           │                      │
           │                      ▼
           │          ┌──────────────────────┐
           │          │ QuizAnswersSubmitted │
           │          │ (QuizResult)         │
           │          └──────────────────────┘
           │
           ├─ Error ──────────┐
           │                   │
           │                   ▼
           │          ┌──────────────────┐
           │          │   QuizError      │
           │          │  (String message)│
           │          └────────┬─────────┘
           │                   │
           │                   ▼ [retry]
           └──────────────────────
                    (back to initial)
```

---

## **Firebase Collections Structure**

```
┌─ Firebase ──────────────────────────────────────────────────────┐
│                                                                  │
│  ┌─ quizzes Collection ──────────────────────────────────────┐  │
│  │                                                             │  │
│  │  Document: quiz_123                                       │  │
│  │  ├─ id: "quiz_123"                                       │  │
│  │  ├─ title: "Introduction Quiz"                          │  │
│  │  ├─ courseId: "course_456"                              │  │
│  │  ├─ instructorId: "instructor_789"                      │  │
│  │  ├─ timeLimitMinutes: 20                                │  │
│  │  ├─ totalQuestions: 20                                  │  │
│  │  ├─ isLocked: false                                     │  │
│  │  ├─ createdAt: 2024-01-15T10:30:00Z                    │  │
│  │  └─ questions: [                                        │  │
│  │      {                                                   │  │
│  │        id: "q1",                                         │  │
│  │        text: "What is...?",                             │  │
│  │        points: 1,                                        │  │
│  │        correctAnswerId: "ans1",                         │  │
│  │        options: [                                        │  │
│  │          {id: "ans1", text: "Option A"},               │  │
│  │          {id: "ans2", text: "Option B"},               │  │
│  │          ...                                             │  │
│  │        ]                                                 │  │
│  │      },                                                  │  │
│  │      ...                                                 │  │
│  │    ]                                                     │  │
│  │                                                             │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌─ quiz_results Collection ─────────────────────────────────┐  │
│  │                                                             │  │
│  │  Document: result_999                                      │  │
│  │  ├─ id: "result_999"                                       │  │
│  │  ├─ quizId: "quiz_123"                                     │  │
│  │  ├─ studentId: "student_111"                              │  │
│  │  ├─ correctAnswers: 18                                     │  │
│  │  ├─ totalQuestions: 20                                     │  │
│  │  ├─ scorePercentage: 90.0                                  │  │
│  │  ├─ passed: true                                           │  │
│  │  ├─ completedAt: 2024-01-15T11:00:00Z                     │  │
│  │  ├─ timeSpentSeconds: 900                                  │  │
│  │  └─ answers: [                                             │  │
│  │      {                                                      │  │
│  │        questionId: "q1",                                   │  │
│  │        selectedAnswerId: "ans1",                           │  │
│  │        isCorrect: true                                     │  │
│  │      },                                                     │  │
│  │      ...                                                    │  │
│  │    ]                                                        │  │
│  │                                                             │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                  │
└──────────────────────────────────────────────────────────────┘
```

---

## **Class Hierarchy & Relationships**

```
DOMAIN LAYER (Business Logic)
├── Quiz (Entity)
│   ├── id: String
│   ├── title: String
│   ├── questions: List<Question>
│   └── ...
│
├── Question (Entity)
│   ├── id: String
│   ├── text: String
│   ├── options: List<Answer>
│   └── ...
│
└── QuizResult (Entity)
    ├── id: String
    ├── quizId: String
    ├── correctAnswers: int
    ├── scorePercentage: double
    └── ...

                    │
                    ▼ (implements)

REPOSITORY PATTERN
├── QuizRepository (Interface)
│   ├── getQuizzesByCourse()
│   ├── getQuizById()
│   ├── createQuiz()
│   ├── submitQuizAnswers()
│   └── ...
│
└── QuizRepositoryImpl (Implementation)
    ├── queries Firestore
    ├── converts Model → Entity
    └── handles business logic

                    │
                    ▼ (uses)

DATA LAYER (Models)
├── QuizModel
├── QuestionModel
├── AnswerModel
├── QuizResultModel
└── StudentAnswerModel

                    │
                    ▼ (persists to)

EXTERNAL SERVICE
└── Firebase Firestore Database
```

---

## **Use Case Workflow Examples**

```
USE CASE: Take a Quiz (Student)

1. GetQuizByIdUseCase
   Input: quizId
   ├─► Repository.getQuizById(quizId)
   ├─► Firestore fetch
   └─► Output: Quiz entity

2. SubmitQuizAnswersUseCase
   Input: quizId, studentId, answers
   ├─► Repository.submitQuizAnswers()
   ├─► Calculate score in repository
   ├─► Save QuizResultModel to Firestore
   └─► Output: void (success/error)

3. GetStudentQuizResultsUseCase
   Input: studentId
   ├─► Repository.getStudentQuizResults(studentId)
   ├─► Firestore query all student results
   ├─► Calculate average score in Cubit
   └─► Output: List<QuizResult>
```

---

## **Integration Points in Main App**

```
main.dart
│
├─ QuizRoutes.getRoutes() registered
│
└─ BlocProvider<QuizCubit>(
    create: (context) => sl<QuizCubit>()
   )

                    │
                    ▼

CourseDetailsScreen
│
└─ ElevatedButton(
    "View Quizzes"
    Navigator.pushNamed('/quiz/list', arguments: courseId)
   )

                    │
                    ▼

QuizzesAndAssessmentsScreen
│
├─ BlocBuilder<QuizCubit, QuizState>
│  └─ Displays QuizCard widgets
│
├─ User clicks "Start Quiz"
│
└─ Navigator.pushNamed('/quiz/question', arguments: quizId)

                    │
                    ▼

QuizQuestionScreen
│
├─ Timer countdown
├─ Question display
├─ User answers
│
└─ User clicks "Submit Quiz"

                    │
                    ▼

QuizCompletionScreen
│
├─ Show results
├─ User can "Retake"
│
└─ Or return to QuizzesAndAssessmentsScreen
```

---

## **File Dependencies Map**

```
quiz_routes.dart
├─ quizzes_assessments_screen.dart
├─ quiz_question_screen.dart
├─ quiz_completion_screen.dart
└─ create_quiz_screen.dart

quizzes_assessments_screen.dart
├─ quiz_cubit.dart (BLoC)
├─ common_widgets.dart
└─ service_locator.dart

quiz_question_screen.dart
├─ quiz_cubit.dart (BLoC)
├─ common_widgets.dart
└─ service_locator.dart

quiz_cubit.dart
├─ quiz_usecases.dart
├─ quiz_entity.dart
└─ quiz_state definitions

quiz_usecases.dart
├─ quiz_repository.dart (interface)
└─ quiz_entity.dart

quiz_repository_impl.dart
├─ quiz_model.dart
├─ quiz_entity.dart
├─ quiz_repository.dart (implements)
└─ firebase_firestore

service_locator.dart
├─ quiz_repository_impl.dart
├─ quiz_usecases.dart
└─ quiz_cubit.dart
```

---

**This architecture ensures:**
✅ Clean separation of concerns
✅ Testability of each layer
✅ Reusability of components
✅ Scalability for future features
✅ Maintainability of codebase
