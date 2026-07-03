import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_state.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_state.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/top_section.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/continue_learning_card.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/course_list.dart';

class HomeScreenStudent extends StatefulWidget {
  const HomeScreenStudent({super.key});

  @override
  State<HomeScreenStudent> createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
  @override
  void initState() {
    super.initState();
    // Initialize HomeCubit with user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthSuccess || authState is AuthSignUpSuccess) {
        final userData = authState is AuthSuccess
            ? authState.userData
            : (authState as AuthSignUpSuccess).userData;
        if (userData != null) {
          // Update the HomeCubit with current user data
          context.read<HomeCubit>().updateUser(userData);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is StudentHomeLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TopSection(userName: state.userName, stats: state.stats),
                  const SizedBox(height: 24),
                  if (state.continueLearningCourse != null)
                    ContinueLearningCard(course: state.continueLearningCourse!),
                  const SizedBox(height: 24),
                  CourseList(courses: state.courses),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
