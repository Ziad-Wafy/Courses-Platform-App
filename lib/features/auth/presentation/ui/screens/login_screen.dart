import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';
import '../../../../home_screen.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_button.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ✅ Validation
  String? _validate() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      return 'Please enter your email.';
    }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    if (password.isEmpty) {
      return 'Please enter your password.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  void _onLogin(BuildContext context) {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.orange),
      );
      return;
    }
    context.read<AuthCubit>().login(
      emailController.text.trim(),
      passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.chatMyMessageTextColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.chatMyMessageTextColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.chatOtherMessageTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Sign in to continue learning",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.chatOtherMessageTextColor.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  CustomTextField(
                    label: "Email",
                    hint: "Enter your email",
                    controller: emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  SizedBox(height: 20.h),
                  CustomTextField(
                    label: "Password",
                    hint: "Enter your password",
                    controller: passwordController,
                    isPassword: _obscurePassword,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixTap: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  state is AuthLoading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                          text: "Sign In",
                          onPressed: () => _onLogin(context),
                        ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: AppColors.secondary,
                          thickness: 1.5,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          "or continue with",
                          style: TextStyle(
                            color: AppColors.chatOtherMessageTextColor
                                .withOpacity(0.5),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: AppColors.secondary,
                          thickness: 1.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SocialButton(
                    text: "Sign in with Google",
                    onPressed: () {
                      context.read<AuthCubit>().signInWithGoogle();
                    },
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.chatOtherMessageTextColor
                              .withOpacity(0.7),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
