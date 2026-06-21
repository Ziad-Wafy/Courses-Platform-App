# 🔗 INTEGRATION GUIDE - Add Quiz Feature to Your App

This guide shows the exact code to add to integrate the quiz feature into your existing app.

---

## **1️⃣ UPDATE main.dart**

Add the import at the top:

```dart
import 'package:courses_platform_app/features/quiz/presentation/routes/quiz_routes.dart';
```

Then update your MaterialApp route definition. Find your current MaterialApp widget and update the `routes` parameter:

```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Learning Management System',
  routes: {
    // Existing routes...
    ...QuizRoutes.getRoutes(),  // ← ADD THIS LINE
  },
  home: const LoginScreen(),
)
```

---

## **2️⃣ ADD "VIEW QUIZZES" BUTTON TO COURSE DETAILS**

Find your course details screen and add this button where appropriate (e.g., in the course content area):

```dart
// Import at top of file
import 'package:courses_platform_app/features/quiz/presentation/routes/quiz_routes.dart';

// In your course details screen, add this button:
ElevatedButton.icon(
  onPressed: () {
    Navigator.pushNamed(
      context,
      QuizRoutes.quizList,
      arguments: courseId,  // Pass your course ID
    );
  },
  icon: const Icon(Icons.quiz),
  label: const Text('View Quizzes'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF4A90E2),
  ),
)
```

---

## **3️⃣ ADD "CREATE QUIZ" BUTTON (FOR INSTRUCTORS)**

If you have an instructor panel, add this button:

```dart
// Import at top of file
import 'package:courses_platform_app/features/quiz/presentation/routes/quiz_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

// In your instructor course management screen:
ElevatedButton.icon(
  onPressed: () {
    Navigator.pushNamed(
      context,
      QuizRoutes.createQuiz,
      arguments: {
        'courseId': courseId,
        'instructorId': FirebaseAuth.instance.currentUser!.uid,
      },
    );
  },
  icon: const Icon(Icons.add),
  label: const Text('Create New Quiz'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF4CAF50),
  ),
)
```

---

## **4️⃣ NAVIGATION EXAMPLES FOR DIFFERENT SCREENS**

### **From Course Card to Quiz List:**
```dart
// In your course card widget
GestureDetector(
  onTap: () {
    Navigator.pushNamed(
      context,
      '/quiz/list',
      arguments: course.id,
    );
  },
  child: // your course card UI
)
```

### **Complete Navigation Chain:**
```dart
// 1. From home/courses screen → Quiz List
Navigator.pushNamed(context, '/quiz/list', arguments: courseId);

// 2. From Quiz List → Quiz Question
Navigator.pushNamed(context, '/quiz/question', arguments: quizId);

// 3. From Quiz Question → Completion (automatic or manual)
Navigator.pushNamed(
  context,
  '/quiz/completion',
  arguments: {
    'correctAnswers': correctCount,
    'totalQuestions': questions.length,
    'scorePercentage': (correctCount / questions.length * 100),
    'quizId': quizId,
    'courseId': courseId,
  },
);

// 4. From Completion → Back to Quiz List
Navigator.pushNamed(context, '/quiz/list', arguments: courseId);
```

---

## **5️⃣ VERIFICATION CHECKLIST**

After adding the code, verify:

- [ ] All imports are added correctly
- [ ] Routes are registered in main.dart
- [ ] Quiz buttons added to course screens
- [ ] Firebase Firestore is initialized
- [ ] `cloud_firestore` package is in pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] No compilation errors: `flutter analyze`
- [ ] App builds successfully: `flutter build apk` or `flutter build ios`

---

## **6️⃣ TESTING THE IMPLEMENTATION**

### **Test Student Flow:**
1. Login as student
2. Navigate to a course
3. Click "View Quizzes"
4. See quiz list
5. Click "Start Quiz"
6. Answer questions and submit
7. View results

### **Test Instructor Flow:**
1. Login as instructor
2. Go to course management
3. Click "Create New Quiz"
4. Fill quiz details and questions
5. Save quiz
6. Verify in student view

---

## **7️⃣ QUICK REFERENCE - API USAGE**

### **Get Quizzes Cubit:**
```dart
// In a widget
BlocProvider.value(
  value: context.read<QuizCubit>(),
  child: // your widget
)

// Or listen to state changes
BlocListener<QuizCubit, QuizState>(
  listener: (context, state) {
    if (state is QuizzesLoaded) {
      print('Quizzes: ${state.quizzes}');
    }
  },
)
```

### **Manual Navigation Example:**
```dart
class MyQuizButton extends StatelessWidget {
  final String courseId;
  
  const MyQuizButton({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/quiz/list',
          arguments: courseId,
        );
      },
      child: const Text('Go to Quizzes'),
    );
  }
}
```

---

## **8️⃣ FILE LOCATIONS REFERENCE**

Use this as a checklist to verify all files are in correct locations:

```
courses_platform_app/lib/features/quiz/
├── data/
│   ├── models/
│   │   └── quiz_model.dart                        ✓
│   └── repositories/
│       └── quiz_repository_impl.dart              ✓
├── domain/
│   ├── entities/
│   │   └── quiz_entity.dart                       ✓
│   ├── repositories/
│   │   └── quiz_repository.dart                   ✓
│   └── usecases/
│       └── quiz_usecases.dart                     ✓
├── presentation/
│   ├── cubit/
│   │   └── quiz_cubit.dart                        ✓
│   ├── routes/
│   │   └── quiz_routes.dart                       ✓
│   └── ui/
│       ├── screens/
│       │   ├── quizzes_assessments_screen.dart    ✓
│       │   ├── quiz_question_screen.dart          ✓
│       │   ├── quiz_completion_screen.dart        ✓
│       │   └── create_quiz_screen.dart            ✓
│       └── widgets/
│           └── common_widgets.dart                ✓
├── README.md                                      ✓
└── (this directory structure complete)
```

---

## **9️⃣ FIREBASE RULES SETUP**

Update your Firestore security rules to allow quiz operations:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow reading and writing quizzes
    match /quizzes/{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Allow reading and writing quiz results
    match /quiz_results/{document=**} {
      allow read: if request.auth.uid == resource.data.studentId;
      allow write: if request.auth.uid == resource.data.studentId;
    }
  }
}
```

---

## **🔟 TROUBLESHOOTING DURING INTEGRATION**

### **Issue: Route not found**
**Solution:**
```dart
// Make sure this is in main.dart BEFORE MaterialApp
import 'package:courses_platform_app/features/quiz/presentation/routes/quiz_routes.dart';

// And add this to MaterialApp
routes: {
  ...QuizRoutes.getRoutes(),  // This line is essential
  // other routes
}
```

### **Issue: "No QuizCubit provided"**
**Solution:**
Check that service_locator.dart is updated with quiz registrations. Run:
```bash
flutter pub get
flutter clean
flutter pub get
```

### **Issue: Firestore "permission denied"**
**Solution:**
Update Firestore rules (see section 9️⃣ above) and restart emulator:
```bash
firebase emulators:start
```

### **Issue: Timer not working**
**Solution:**
Verify quiz has `timeLimitMinutes > 0` in Firestore and TimerMixin is properly implemented.

---

## **1️⃣1️⃣ CUSTOMIZATION OPTIONS**

### **Change Primary Color**
Find all instances of `Color(0xFF4A90E2)` and replace with your color:

```dart
// In common_widgets.dart and screens
color: const Color(0xFFYourColor),  // Replace with your color code
```

### **Change Passing Score**
File: `lib/features/quiz/domain/entities/quiz_entity.dart`

```dart
bool get passed => scorePercentage >= 60;  // Change 60 to your threshold
```

### **Adjust Timer Alert Threshold**
File: `lib/features/quiz/presentation/ui/widgets/common_widgets.dart`

```dart
color: remainingSeconds < 300  // Change 300 (5 minutes) to your preference
    ? Colors.red.withOpacity(0.1)
    : Colors.grey.withOpacity(0.1),
```

---

## **1️⃣2️⃣ PERFORMANCE OPTIMIZATION**

For large quiz datasets:

1. **Add pagination to quiz list:**
```dart
// In quiz_repository_impl.dart
Future<List<Quiz>> getQuizzesByCourse(String courseId, {int page = 1}) async {
  final perPage = 10;
  final snapshot = await firebaseFirestore
      .collection(_quizzesCollection)
      .where('courseId', isEqualTo: courseId)
      .limit(perPage)
      .offset((page - 1) * perPage)
      .get();
  // ... rest of implementation
}
```

2. **Cache quiz data:**
```dart
// Use Hive or shared_preferences for local caching
// This reduces Firestore reads
```

3. **Lazy load questions:**
```dart
// Load questions only when quiz is opened, not in list view
```

---

## **FINAL CHECKLIST**

```
🔷 Code Integration
  ☐ main.dart updated with imports and routes
  ☐ Quiz buttons added to course screens
  ☐ Navigation tested end-to-end

🔷 Dependencies
  ☐ flutter_bloc added to pubspec.yaml
  ☐ cloud_firestore added to pubspec.yaml
  ☐ flutter pub get executed
  ☐ flutter analyze returns no errors

🔷 Firebase
  ☐ Firestore initialized
  ☐ Collections created (quizzes, quiz_results)
  ☐ Security rules updated
  ☐ Test read/write permissions

🔷 Testing
  ☐ Create quiz works
  ☐ Take quiz works
  ☐ View results works
  ☐ Timer functions correctly
  ☐ Score calculation is accurate
  ☐ Responsive on different screen sizes

🔷 Documentation
  ☐ README.md reviewed
  ☐ Code comments understood
  ☐ Integration guide followed
  ☐ Backup created before changes
```

---

**Ready to integrate? Start with Step 1️⃣ and follow sequentially!**

**Questions?** Refer to the detailed README.md in the quiz feature folder.
