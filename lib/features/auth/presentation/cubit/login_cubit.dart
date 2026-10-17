import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.loginUseCase) : super(LoginInitial());

  final LoginUseCase loginUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(LoginSuccess()),
    );
  }
}
