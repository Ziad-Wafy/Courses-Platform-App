import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final int maxLines;
  final TextEditingController? controller;
  final VoidCallback? onSuffixTap; // ✅ مضاف: للتحكم في إظهار/إخفاء الباسورد

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.maxLines = 1,
    this.controller,
    this.onSuffixTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.chatOtherMessageTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: isPassword,
          maxLines: isPassword ? 1 : maxLines, // ✅ maxLines=1 دايمًا مع Password
          style: TextStyle(
            color: AppColors.chatOtherMessageTextColor,
            fontSize: 13.sp,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.chatOtherMessageTextColor.withOpacity(0.4),
              fontSize: 13.sp,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary, size: 18.sp)
                : null,
            // ✅ السفكس أيقونة قابلة للضغط
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(
                      suffixIcon,
                      color: AppColors.primary,
                      size: 18.sp,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.chatMyMessageTextColor,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}