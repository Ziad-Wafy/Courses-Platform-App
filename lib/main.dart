import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/screens/student_courses_screen.dart';
//import 'package:learning_management_system/features/quiz/presentation/routes/quiz_routes.dart';

import 'firebase_options.dart';
import 'core/utils/service_locator.dart' as di;

import 'features/auth/presentation/cubit/auth_cubit.dart';
//import 'features/auth/presentation/ui/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase already initialized: $e");
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
        return BlocProvider(
          create: (context) => di.sl<AuthCubit>(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Learning Management System',
            //routes: QuizRoutes.getRoutes(),
            home: const StudentCoursesScreen(),
          ),
        );
      },
    );
  }
}
