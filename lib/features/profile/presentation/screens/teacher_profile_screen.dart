import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../quiz/presentation/routes/quiz_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_section.dart';
import '../widgets/stat_item.dart';
import '../widgets/stats_card.dart';
import 'edit_profile_screen.dart';

class TeacherProfileScreen extends StatelessWidget {
  final ProfileEntity profile;

  const TeacherProfileScreen({Key? key, required this.profile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = profile.teacherStats;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Blue Header ──────────────────────────────────────
            ProfileHeader(profile: profile),

            // ── Stats Card ────────────────────────────────────────
            Transform.translate(
              offset: Offset(0, -20.h),
              child: StatsCard(
                stats: [
                  StatItem(
                    icon: Icons.menu_book_rounded,
                    value: '${stats?.courses ?? 0}',
                    label: 'Courses',
                  ),
                  StatItem(
                    icon: Icons.people_outline_rounded,
                    value: '${stats?.students ?? 0}',
                    label: 'Students',
                  ),
                  StatItem(
                    icon: Icons.star_rounded,
                    value:
                        '${stats?.rating.toStringAsFixed(1) ?? '0.0'}',
                    label: 'Rating',
                  ),
                  StatItem(
                    icon: Icons.workspace_premium_outlined,
                    value: '${stats?.issued ?? 0}',
                    label: 'Issued',
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // ── Account Settings ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SettingsSection(
                title: 'Account Settings',
                items: [
                  SettingsSectionItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // ✅ نمرر الـ ProfileCubit عشان العمليات تشتغل
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProfileCubit>(),
                            child: EditProfileScreen(profile: profile),
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsSectionItem(
                    icon: Icons.quiz_outlined,
                    title: 'Create New Quiz',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        QuizRoutes.createQuiz,
                        arguments: {
                          'courseId': 'course_123', // TODO: Get actual course ID
                          'instructorId': profile.uid,
                        },
                      );
                    },
                  ),
                  SettingsSectionItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    onTap: () {
                      // TODO: navigate to Privacy screen
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ── Support ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SettingsSection(
                title: 'Support',
                items: [
                  SettingsSectionItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    onTap: () {
                      // TODO: navigate to Help Center
                    },
                  ),
                  SettingsSectionItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    onTap: () {
                      // TODO: navigate to About screen
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Log Out ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const _LogOutButton(),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // ✅ AuthCubit → signOut → AuthWrapper يتكفل بالتوجيه لـ Login
        await context.read<AuthCubit>().signOut();
      },
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.chatMyMessageTextColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}