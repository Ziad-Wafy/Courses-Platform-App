import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_state.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_cubit.dart';
import 'package:learning_management_system/features/main_layout/presentation/cubit/home_state.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/top_section.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/continue_learning_card.dart';
import 'package:learning_management_system/features/main_layout/presentation/ui/home/course_list.dart';

class HomeScreenStudent extends StatelessWidget {
  const HomeScreenStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final userData =
            (authState is AuthSuccess || authState is AuthSignUpSuccess)
            ? (authState is AuthSuccess
                  ? authState.userData
                  : (authState as AuthSignUpSuccess).userData)
            : null;

        if (userData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider(
          create: (_) => HomeCubit(
            firestore: FirebaseFirestore.instance,
            currentUser: userData,
          ),
          child: Scaffold(
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
                        TopSection(
                          userName: state.userName,
                          stats: state.stats,
                        ),
                        const SizedBox(height: 24),
                        if (state.continueLearningCourse != null)
                          ContinueLearningCard(
                            course: state.continueLearningCourse!,
                          ),
                        const SizedBox(height: 24),
                        CourseList(courses: state.courses),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}
