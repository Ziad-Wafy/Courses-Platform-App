import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/chat/presentation/state_manegment.dart/cubit/chat_cubit.dart';
import 'package:learning_management_system/features/chat/presentation/ui/screens/chat_screen.dart';

import 'firebase_options.dart';
import 'core/utils/service_locator.dart' as di;

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/ui/screens/login_screen.dart';

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
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (context) => di.sl<AuthCubit>()),
            BlocProvider<ChatCubit>(create: (context) => di.sl<ChatCubit>())
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Learning Management System',
            home: const AuthWrapper(),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // TODO: استبدلها بشاشة الـ Home عند توفرها
          return ChatScreen();
          // مثال:
          // return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
