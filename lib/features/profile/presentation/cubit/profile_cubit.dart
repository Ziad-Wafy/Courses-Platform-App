import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/profile_entity.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  ProfileCubit({
    required this.firebaseAuth,
    required this.firestore,
    required this.storage,
  }) : super(ProfileInitial());

  void loadProfile() {
    emit(ProfileLoading());
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) {
      emit(ProfileError(message: 'User not found. Please login again.'));
      return;
    }

    // Listen to user document for real-time updates
    _userSubscription = firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .snapshots()
        .listen(
          (doc) {
            if (!doc.exists) {
              emit(ProfileError(message: 'Profile data not found.'));
              return;
            }

            final data = doc.data()!;
            final role = data['role'] as String? ?? 'Student';
            final fullName =
                data['fullName'] as String? ??
                firebaseUser.displayName ??
                'User';
            final email = data['email'] as String? ?? firebaseUser.email ?? '';
            final bio = data['bio'] as String?;
            final phoneNumber = data['phoneNumber'] as String?;
            final avatarUrl = data['avatarUrl'] as String?;

            final ProfileEntity profile;

            if (role == 'Teacher') {
              profile = ProfileEntity(
                uid: firebaseUser.uid,
                fullName: fullName,
                email: email,
                role: role,
                bio: bio,
                phoneNumber: phoneNumber,
                avatarUrl: avatarUrl,
                teacherStats: const TeacherStats(
                  courses: 8,
                  students: 546,
                  rating: 4.8,
                  issued: 12,
                ),
              );
            } else {
              profile = ProfileEntity(
                uid: firebaseUser.uid,
                fullName: fullName,
                email: email,
                role: role,
                bio: bio,
                phoneNumber: phoneNumber,
                avatarUrl: avatarUrl,
                studentStats: const StudentStats(
                  enrolled: 8,
                  completed: 12,
                  certificates: 5,
                  avgScore: 87,
                ),
              );
            }

            emit(ProfileLoaded(profile: profile));
          },
          onError: (e) {
            emit(
              ProfileError(message: 'Failed to load profile: ${e.toString()}'),
            );
          },
        );
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String bio,
    File? avatarFile,
  }) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileLoading());
    try {
      final uid = currentState.profile.uid;
      String? newAvatarUrl = currentState.profile.avatarUrl;

      // ✅ رفع الصورة — لو فشل، نكمل بدونه (non-fatal)
      if (avatarFile != null) {
        try {
          final ref = storage.ref().child('avatars/$uid.jpg');
          await ref.putFile(avatarFile);
          newAvatarUrl = await ref.getDownloadURL();
        } catch (storageError) {
          // ✅ Storage فشل (rules أو bucket مش enabled)
          // بنكمل الحفظ بدون تحديث الصورة — مش بنوقف العملية كلها
          debugPrint('Avatar upload failed (skipped): $storageError');
        }
      }

      // ✅ حفظ البيانات في Firestore
      final updateData = <String, dynamic>{
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'bio': bio,
        if (newAvatarUrl != null) 'avatarUrl': newAvatarUrl,
      };
      await firestore.collection('users').doc(uid).update(updateData);

      final updatedProfile = currentState.profile.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        bio: bio,
        avatarUrl: newAvatarUrl,
      );

      emit(ProfileUpdateSuccess(profile: updatedProfile));
      emit(ProfileLoaded(profile: updatedProfile));
    } catch (e) {
      // ✅ رجّع الـ state القديم أولاً عشان الشاشة متتمسحش
      emit(ProfileLoaded(profile: currentState.profile));
      emit(ProfileError(message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
