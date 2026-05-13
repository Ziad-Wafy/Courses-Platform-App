import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_color.dart';
import '../../../../home_screen.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/role_selector.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'Student';

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ Validation كاملة
  String? _validate() {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      return 'Please enter your full name.';
    }
    if (name.length < 3) {
      return 'Name must be at least 3 characters.';
    }
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
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  void _onSignUp(BuildContext context) {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.orange),
      );
      return;
    }
    context.read<AuthCubit>().signUp(
          emailController.text.trim(),
          passwordController.text,
          fullNameController.text.trim(),
          _selectedRole,
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: AppColors.chatMyMessageTextColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.chatOtherMessageTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Join us and start learning today",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.chatOtherMessageTextColor.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "I am a",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.chatOtherMessageTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  RoleSelector(
                    selectedRole: _selectedRole,
                    onRoleSelected: (role) {
                      setState(() => _selectedRole = role);
                    },
                  ),
                  SizedBox(height: 24.h),
                  CustomTextField(
                    label: "Full Name",
                    hint: "John Doe",
                    prefixIcon: Icons.person_outline,
                    controller: fullNameController,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: "Email",
                    hint: "example@email.com",
                    prefixIcon: Icons.email_outlined,
                    controller: emailController,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: "Password",
                    hint: "Enter your password",
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    isPassword: _obscurePassword,
                    controller: passwordController,
                    onSuffixTap: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: "Confirm Password",
                    hint: "Re-enter your password",
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    isPassword: _obscureConfirmPassword,
                    controller: confirmPasswordController,
                    onSuffixTap: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  SizedBox(height: 32.h),
                  state is AuthLoading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                          text: "Create Account",
                          onPressed: () => _onSignUp(context),
                        ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.chatOtherMessageTextColor.withOpacity(0.7),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Sign In",
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