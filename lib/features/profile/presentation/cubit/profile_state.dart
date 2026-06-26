import '../../domain/entities/profile_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  ProfileLoaded({required this.profile});
}

// ✅ state منفصلة للـ update — تمنع تعارض الـ BlocListener في EditProfileScreen
class ProfileUpdateSuccess extends ProfileState {
  final ProfileEntity profile;
  ProfileUpdateSuccess({required this.profile});
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
}