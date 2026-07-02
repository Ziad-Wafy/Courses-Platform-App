import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_management_system/core/theme/app_color.dart';
import 'package:learning_management_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:learning_management_system/features/profile/domain/entities/profile_entity.dart';
import 'package:learning_management_system/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:learning_management_system/features/profile/presentation/cubit/profile_state.dart';
import 'package:learning_management_system/features/profile/presentation/widgets/profile_header.dart';
import 'package:learning_management_system/features/profile/presentation/widgets/settings_section.dart';
import 'package:learning_management_system/features/profile/presentation/widgets/stat_item.dart';
import 'package:learning_management_system/features/profile/presentation/widgets/stats_card.dart';
import 'edit_profile_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  final ProfileEntity profile;

  const StudentProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final stats = profile.studentStats;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      // ✅ BlocListener هنا يسمع لـ ProfileUpdateSuccess ويحدّث الشاشة
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // لو المستخدم عدّل البروفايل وعمل pop من EditProfile،
          // الـ ProfileScreen الأب هيبعت ProfileLoaded الجديد تلقائياً
          // مش محتاجين نعمل حاجة هنا
        },
        child: SingleChildScrollView(
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
                      value: '${stats?.enrolled ?? 0}',
                      label: 'Enrolled',
                    ),
                    StatItem(
                      icon: Icons.emoji_events_outlined,
                      value: '${stats?.completed ?? 0}',
                      label: 'Completed',
                    ),
                    StatItem(
                      icon: Icons.workspace_premium_outlined,
                      value: '${stats?.certificates ?? 0}',
                      label: 'Certificates',
                    ),
                    StatItem(
                      icon: Icons.bar_chart_rounded,
                      value: '${stats?.avgScore.toInt() ?? 0}%',
                      label: 'Avg Score',
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
                            // ✅ نمرر الـ profile الحالي لتعبئة الفورم
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProfileCubit>(),
                              child: EditProfileScreen(profile: profile),
                            ),
                          ),
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
              color: Colors.black.withValues(alpha: 0.04),
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