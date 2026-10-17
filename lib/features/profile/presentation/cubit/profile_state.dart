import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  ProfileLoaded(this.user);

  final UserEntity user;
}

class ProfileError extends ProfileState {
  ProfileError(this.errorMessage);

  final String errorMessage;
}

class ProfileLoggedOut extends ProfileState {}
