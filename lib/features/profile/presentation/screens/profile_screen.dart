import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';
import '../../../../../core/utils/service_locator.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../../domain/entities/profile_entity.dart';
import 'student_profile_screen.dart';
import 'teacher_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // ── Loading ──────────────────────────────────────────
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Scaffold(
              backgroundColor: AppColors.secondary,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          // ── Error ────────────────────────────────────────────
          if (state is ProfileError) {
            return Scaffold(
              backgroundColor: AppColors.secondary,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.chatOtherMessageTextColor,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () =>
                            context.read<ProfileCubit>().loadProfile(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // ── Loaded أو UpdateSuccess → نجيب الـ profile بدون cast ──
          // ✅ الحل: نستخدم helper method تعيد ProfileEntity? بدل الـ cast المتداخل
          final profile = _extractProfile(state);
          if (profile != null) {
            return profile.isTeacher
                ? TeacherProfileScreen(profile: profile)
                : StudentProfileScreen(profile: profile);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ✅ helper منفصل — يزيل الـ cast تماماً ويوضح النية
  ProfileEntity? _extractProfile(ProfileState state) {
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileUpdateSuccess) return state.profile;
    return null;
  }
}
