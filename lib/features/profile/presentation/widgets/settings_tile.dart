import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.chatMyMessageTextColor,
      borderRadius: BorderRadius.only(
        topLeft: isFirst ? Radius.circular(12.r) : Radius.zero,
        topRight: isFirst ? Radius.circular(12.r) : Radius.zero,
        bottomLeft: isLast ? Radius.circular(12.r) : Radius.zero,
        bottomRight: isLast ? Radius.circular(12.r) : Radius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? Radius.circular(12.r) : Radius.zero,
          topRight: isFirst ? Radius.circular(12.r) : Radius.zero,
          bottomLeft: isLast ? Radius.circular(12.r) : Radius.zero,
          bottomRight: isLast ? Radius.circular(12.r) : Radius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: AppColors.chatOtherMessageTextColor.withValues(alpha: 0.7),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.chatOtherMessageTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12.sp,
                color: AppColors.chatOtherMessageTextColor.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}