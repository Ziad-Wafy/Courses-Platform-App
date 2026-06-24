import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 1. أضف الاستيراد
//import 'package:learning_management_system/features/courses_student_side/presentation/ui/screens/Lesson_Content_Screen.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/screens/student_courses_screen.dart';
//import 'package:learning_management_system/features/courses_student_side/presentation/ui/screens/Lesson%20Content%20Screen.dart';
//import 'package:learning_management_system/features/courses_student_side/presentation/ui/screens/student_courses_screen.dart';
//import 'package:learning_management_system/features/courses_student_side/presentation/ui/screens/course_details_screen.dart';
//import 'features/auth/presentation/ui/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. تغليف التطبيق بـ ScreenUtilInit
    return ScreenUtilInit(
      // مقاس الشاشة الذي بنيت عليه التصميم (مثلاً مقاس iPhone 13 أو Android standard)
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Clean Arch App',
          // 3. تأكد أن home داخل الـ builder
          home: const StudentCoursesScreen(),
        );
      },
    );
  }
}
