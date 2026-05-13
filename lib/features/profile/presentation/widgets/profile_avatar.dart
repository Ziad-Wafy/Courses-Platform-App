import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_color.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.chatMyMessageTextColor,
              width: 3.w,
            ),
          ),
          child: Center(
            child: Text("👤", style: TextStyle(fontSize: 36.sp)),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.r),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.chatMyMessageTextColor,
              width: 1.5.w,
            ),
          ),
          child: Icon(
            Icons.camera_alt,
            color: AppColors.chatMyMessageTextColor,
            size: 14.sp,
          ),
        ),
      ],
    );
  }
}
