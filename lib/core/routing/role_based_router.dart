import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_state.dart';
import 'main_navigation_wrapper.dart';

class RoleBasedRouter extends StatelessWidget {
  const RoleBasedRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Handle auth state changes if needed
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AuthSuccess || state is AuthSignUpSuccess) {
            final userData = state is AuthSuccess
                ? state.userData
                : (state as AuthSignUpSuccess).userData;

            if (userData == null) {
              // If user data is not available, try to fetch it
              final user = state is AuthSuccess
                  ? state.user
                  : (state as AuthSignUpSuccess).user;
              if (user != null) {
                context.read<AuthCubit>().fetchUserData(user.uid);
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const Scaffold(
                body: Center(child: Text('Error loading user data')),
              );
            }

            // Route based on role using MainNavigationWrapper
            return MainNavigationWrapper(userData: userData);
          }

          return const Scaffold(
            body: Center(child: Text('Authentication required')),
          );
        },
      ),
    );
  }
}
