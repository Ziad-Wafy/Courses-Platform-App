import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_color.dart';
import '../../../auth/presentation/ui/widgets/back_app_bar.dart';
import '../../../auth/presentation/ui/widgets/custom_text_field.dart';
import '../../../auth/presentation/ui/widgets/primary_button.dart';
import '../../domain/entities/profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileEntity profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  File? _pickedImage;
  int _wordCount = 0;
  static const int _maxWords = 100;
  static const double _headerH = 140;
  static const double _avatarD = 90;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.fullName);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phoneNumber ?? '');
    _bioController = TextEditingController(text: p.bio ?? '');
    _wordCount = _countWords(_bioController.text);
    _bioController.addListener(() => _onBioChanged(_bioController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  int _countWords(String text) {
    final t = text.trim();
    return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
  }

  void _onBioChanged(String value) {
    final count = _countWords(value);
    if (count > _maxWords) {
      final allowed = value
          .trim()
          .split(RegExp(r'\s+'))
          .take(_maxWords)
          .join(' ');
      _bioController.value = TextEditingValue(
        text: allowed,
        selection: TextSelection.collapsed(offset: allowed.length),
      );
      setState(() => _wordCount = _maxWords);
    } else {
      if (_wordCount != count) setState(() => _wordCount = count);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    await context.read<ProfileCubit>().updateProfile(
      fullName: name,
      phoneNumber: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
      avatarFile: _pickedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully! ✅'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.chatMyMessageTextColor,
        body: Stack(
          children: [
            // ── 1. Column: blue header + white body ──────────────
            Column(
              children: [
                Container(
                  height: _headerH.h,
                  color: AppColors.primary,
                  child: const BackAppBar(
                    title: "Edit Profile",
                    isWhiteContent: true,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      _avatarD.w / 2 + 20.h,
                      20.w,
                      24.h,
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: "Full Name",
                          hint: "John Doe",
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                        ),
                        SizedBox(height: 14.h),
                        _ReadOnlyEmailField(email: _emailController.text),
                        SizedBox(height: 14.h),
                        CustomTextField(
                          label: "Phone Number",
                          hint: "+1 234 567 890",
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        SizedBox(height: 14.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              label: "Bio",
                              hint: "Tell us about yourself...",
                              controller: _bioController,
                              maxLines: 4,
                            ),
                            SizedBox(height: 4.h),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$_wordCount / $_maxWords words',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: _wordCount >= _maxWords
                                      ? Colors.red
                                      : AppColors.chatOtherMessageTextColor
                                            .withOpacity(0.5),
                                  fontWeight: _wordCount >= (_maxWords * 0.85)
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 28.h),
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) {
                            final loading = state is ProfileLoading;
                            return PrimaryButton(
                              text: loading ? "Saving..." : "Save Changes",
                              icon: loading ? null : Icons.save_outlined,
                              onPressed: loading ? null : _saveChanges,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── 2. Avatar على فوق كل حاجة — مش هيتقطع ──────────
            // ✅ top = نهاية الـ header ناقص نص قطر الـ avatar
            Positioned(
              top: _headerH.h - _avatarD.w / 2,
              left: 0,
              right: 0,
              child: Center(child: _buildAvatar()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: _avatarD.w,
            height: _avatarD.w,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.chatMyMessageTextColor,
                width: 3.w,
              ),
            ),
            child: ClipOval(child: _avatarContent()),
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
      ),
    );
  }

  Widget _avatarContent() {
    if (_pickedImage != null) {
      return Image.file(
        _pickedImage!,
        width: _avatarD.w,
        height: _avatarD.w,
        fit: BoxFit.cover,
      );
    }
    if (widget.profile.avatarUrl?.isNotEmpty == true) {
      return Image.network(
        widget.profile.avatarUrl!,
        width: _avatarD.w,
        height: _avatarD.w,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) => _emoji(),
      );
    }
    return _emoji();
  }

  Widget _emoji() => Center(
    child: Text(
      widget.profile.isTeacher ? '👩‍🏫' : '👨‍🎓',
      style: TextStyle(fontSize: 36.sp),
    ),
  );
}

// ── Email read-only widget ─────────────────────────────────────────────────
class _ReadOnlyEmailField extends StatelessWidget {
  final String email;
  const _ReadOnlyEmailField({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: TextStyle(
            color: AppColors.chatOtherMessageTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.secondary, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppColors.primary.withValues(alpha: 0.5),
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  email,
                  style: TextStyle(
                    color: AppColors.chatOtherMessageTextColor.withValues(alpha: 0.5),
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline,
                color: AppColors.chatOtherMessageTextColor.withValues(alpha: 0.3),
                size: 14.sp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
