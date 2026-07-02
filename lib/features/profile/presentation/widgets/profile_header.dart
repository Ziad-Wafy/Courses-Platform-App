import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_management_system/core/theme/app_color.dart';
import 'package:learning_management_system/features/profile/domain/entities/profile_entity.dart';
import 'package:learning_management_system/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:learning_management_system/features/profile/presentation/screens/edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileEntity profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        bottom: 28.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: title + edit icon ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profile",
                style: TextStyle(
                  color: AppColors.chatMyMessageTextColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProfileCubit>(),
                        child: EditProfileScreen(profile: profile),
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.chatMyMessageTextColor,
                  size: 22.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // ── Avatar + name/email/role ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Avatar — يعرض الصورة المرفوعة لو موجودة
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.chatSelectedCourseColor,
                  borderRadius: BorderRadius.circular(14.r),
                  // ✅ border خفيف يوضح حدود الـ avatar
                  border: Border.all(
                    color: AppColors.chatMyMessageTextColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13.r),
                  child: _buildAvatarContent(),
                ),
              ),

              SizedBox(width: 14.w),

              // Name / email / role badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: TextStyle(
                        color: AppColors.chatMyMessageTextColor,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      profile.email,
                      style: TextStyle(
                        color:
                            AppColors.chatMyMessageTextColor.withValues(alpha: 0.8),
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // Role badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.chatMyMessageTextColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        profile.role,
                        style: TextStyle(
                          color: AppColors.chatMyMessageTextColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ✅ Bio — تظهر تحت الـ avatar row لو موجودة
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.chatMyMessageTextColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                profile.bio!,
                style: TextStyle(
                  color: AppColors.chatMyMessageTextColor.withValues(alpha: 0.9),
                  fontSize: 12.sp,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ يعرض الصورة المرفوعة من Firebase Storage
  // لو مفيش صورة يعرض الـ default emoji حسب الـ role
  Widget _buildAvatarContent() {
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return Image.network(
        profile.avatarUrl!,
        width: 60.w,
        height: 60.w,
        fit: BoxFit.cover,
        // ✅ loading indicator أثناء تحميل الصورة
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
        // ✅ لو الصورة اتكسرت يرجع للـ emoji
        errorBuilder: (_, __, ___) => _defaultEmoji(),
      );
    }
    return _defaultEmoji();
  }

  Widget _defaultEmoji() {
    return Center(
      child: Text(
        profile.isTeacher ? '👩‍🏫' : '👨‍🎓',
        style: TextStyle(fontSize: 28.sp),
      ),
    );
  }
}