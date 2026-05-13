import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../widgets/back_app_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'reset_link_sent_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // ✅ Validation
  String? _validate() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      return 'Please enter your email.';
    }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  void _onSendReset(BuildContext context) {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.orange),
      );
      return;
    }
    context.read<AuthCubit>().resetPassword(emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResetLinkSentScreen(
                email: emailController.text.trim(),
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.chatMyMessageTextColor,
          appBar: const BackAppBar(title: "Back to Login"),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.chatSelectedCourseColor,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.email_rounded,
                      color: AppColors.primary,
                      size: 50.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.chatOtherMessageTextColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Enter your email and we'll send you reset instructions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.chatOtherMessageTextColor.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  CustomTextField(
                    label: "Email",
                    hint: "Enter your email",
                    controller: emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  SizedBox(height: 32.h),
                  state is AuthLoading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                          text: "Send Reset Link",
                          onPressed: () => _onSendReset(context),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}