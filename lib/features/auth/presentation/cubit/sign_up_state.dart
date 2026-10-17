import '../../domain/entities/user_entity.dart';

abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  SignUpSuccess(this.user);

  final UserEntity user;
}

class SignUpFailure extends SignUpState {
  SignUpFailure(this.errorMessage);

  final String errorMessage;
}
