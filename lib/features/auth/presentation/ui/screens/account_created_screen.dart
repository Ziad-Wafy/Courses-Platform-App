import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/auth_cubit.dart';
import '../../../../../main.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatMyMessageTextColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: AppColors.chatMyMessageTextColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.secondary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF3DE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: const Color(0xFF3B6D11),
                    size: 44.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "Account Created!",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.chatOtherMessageTextColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Your account has been created successfully.\nSign in now to start learning.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.chatOtherMessageTextColor.withOpacity(
                      0.55,
                    ),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    // ✅ بيمسح كل الـ stack ويروح AuthWrapper عشان يعرض شاشة الدخول
                    onPressed: () async {
                      await context.read<AuthCubit>().signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuthWrapper(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.login_rounded,
                      color: AppColors.chatMyMessageTextColor,
                      size: 18.sp,
                    ),
                    label: Text(
                      "Go to Login",
                      style: TextStyle(
                        color: AppColors.chatMyMessageTextColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
