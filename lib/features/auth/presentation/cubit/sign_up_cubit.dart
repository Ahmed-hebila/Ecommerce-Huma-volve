import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_up_usecase.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this.signUpUseCase) : super(SignUpInitial());

  final SignUpUseCase signUpUseCase;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(SignUpLoading());
    final result = await signUpUseCase(
      SignUpParams(name: name, email: email, password: password),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(SignUpFailure(failure.message)),
      (user) => emit(SignUpSuccess(user)),
    );
  }
}
