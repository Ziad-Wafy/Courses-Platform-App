import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'core/utils/service_locator.dart' as di;
import 'features/auth/presentation/ui/screens/login_screen.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

void main() async {
  // 1. تأمين ربط الفريمورك
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة Firebase بحماية من التكرار
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // في حالة وجود خطأ "الطلب مكرر" تجاهله واكمل التشغيل
    debugPrint("Firebase already initialized: $e");
  }

  // 3. تهيئة الـ Dependency Injection
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
          // استخدام المرجع المباشر من sl لضمان الاستقرار
          create: (context) => di.sl<AuthCubit>(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Learning Management System',
            home: const LoginScreen(),
          ),
        );
      },
    );
  }
}