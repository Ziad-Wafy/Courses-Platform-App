import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isWhiteContent;

  const BackAppBar({Key? key, required this.title, this.isWhiteContent = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isWhiteContent
        ? AppColors.chatMyMessageTextColor
        : AppColors.chatOtherMessageTextColor;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios, color: color, size: 18.sp),
                  SizedBox(width: 4.w),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(52.h);
}