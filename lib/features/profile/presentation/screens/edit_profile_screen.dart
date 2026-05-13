import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_color.dart';
import '../../../auth/presentation/ui/widgets/back_app_bar.dart';
import '../../../auth/presentation/ui/widgets/custom_text_field.dart';
import '../../../auth/presentation/ui/widgets/primary_button.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatMyMessageTextColor,
      body: Stack(
        children: [
          Container(
            height: 0.22.sh,
            width: double.infinity,
            color: AppColors.primary,
            child: const Column(
              children: [
                BackAppBar(
                  title: "Edit Profile",
                  isWhiteContent: true,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.82.sh,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: AppColors.chatMyMessageTextColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Transform.translate(
                      offset: Offset(0, -45.h),
                      child: const ProfileAvatar(),
                    ),
                    SizedBox(height: 4.h),
                    const CustomTextField(
                      label: "Full Name",
                      hint: "John Doe",
                    ),
                    SizedBox(height: 14.h),
                    const CustomTextField(
                      label: "Email",
                      hint: "example@email.com",
                    ),
                    SizedBox(height: 14.h),
                    const CustomTextField(
                      label: "Phone Number",
                      hint: "+1 234 567 890",
                    ),
                    SizedBox(height: 14.h),
                    const CustomTextField(
                      label: "Bio",
                      hint: "Tell us about yourself...",
                      maxLines: 4,
                    ),
                    SizedBox(height: 28.h),
                    PrimaryButton(
                      text: "Save Changes",
                      icon: Icons.save_outlined,
                      onPressed: () {},
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}