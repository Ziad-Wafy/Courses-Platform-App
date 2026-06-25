import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'core/utils/service_locator.dart' as di;
import 'features/auth/presentation/ui/screens/login_screen.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
// import 'features/home_screen.dart';

void main() async {
  // ✅ ضمان التهيئة قبل أي عمليات تزامن
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase Initialization ─────────────────────────────────
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Critical: Firebase initialization failed: $e");
  }

  // ── Dependency Injection ─────────────────────────────────────
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
        // ✅ استخدام MultiBlocProvider يسهل عليك إضافة الـ Cubits القادمة
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => di.sl<AuthCubit>(),
            ),
          ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Learning Management System',
            home: AuthWrapper(),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── حالة التحميل ─────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ── مستخدم مسجل بالفعل ─────────────────────────────────
        if (snapshot.hasData && snapshot.data != null) {
          // return const HomeScreen();
        }

        // ── لا يوجد مستخدم -> شاشة الدخول ──────────────────────
        return const LoginScreen();
      },
    );
  }
}