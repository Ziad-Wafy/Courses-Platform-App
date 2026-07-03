import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/chat/presentation/state_management/cubit/chat_cubit.dart';

import 'package:learning_management_system/firebase_options.dart';
import 'package:learning_management_system/core/utils/service_locator.dart' as di;
import 'package:learning_management_system/core/routing/role_based_router.dart';

import 'package:learning_management_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_state.dart';
import 'package:learning_management_system/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:learning_management_system/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';
import 'package:learning_management_system/features/courses_student_side/presentation/ui/screens/course_details_screen.dart';
import 'package:learning_management_system/features/quiz/presentation/routes/quiz_routes.dart';

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
            BlocProvider<ChatCubit>(create: (context) => di.sl<ChatCubit>()),
            BlocProvider<ProfileCubit>(
              create: (context) => di.sl<ProfileCubit>(),
            ),
            BlocProvider<HomeCubit>(create: (context) => di.sl<HomeCubit>()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Learning Management System',
            routes: QuizRoutes.getRoutes(),
            home: const AuthWrapper(),
            onGenerateRoute: (settings) {
              if (settings.name == '/course-details') {
                return MaterialPageRoute(
                  builder: (_) => CourseDetailsScreen(course: settings.arguments),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes and initialize ProfileCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().stream.listen((state) {
        if (state is AuthSuccess || state is AuthSignUpSuccess) {
          context.read<ProfileCubit>().loadProfile();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthSuccess || state is AuthSignUpSuccess) {
          return const RoleBasedRouter();
        }

        return const LoginScreen();
      },
    );
  }
}
