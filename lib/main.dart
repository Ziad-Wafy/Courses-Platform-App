import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'firebase_options.dart';
import 'core/utils/service_locator.dart' as di;
import 'features/quiz/presentation/routes/quiz_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  await di.setupServiceLocator();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quiz Feature Standalone',
          routes: QuizRoutes.getRoutes(),
          home: const QuizEntryPoint(),
        );
      },
    );
  }
}

class QuizEntryPoint extends StatelessWidget {
  const QuizEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Feature Standalone')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Standalone Quiz Feature',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/quiz/list',
                  arguments: 'course_123', // Default test course ID
                );
              },
              child: const Text('View Quizzes (Student)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please ensure you are signed in via Firebase for instructor features')),
                  );
                  return;
                }
                Navigator.pushNamed(
                  context,
                  '/quiz/create',
                  arguments: {
                    'courseId': 'course_123',
                    'instructorId': user.uid,
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Create New Quiz (Instructor)'),
            ),
          ],
        ),
      ),
    );
  }
}
