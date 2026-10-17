import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/get_profile_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.getProfileUseCase, required this.logoutUseCase})
    : super(ProfileLoading());

  final GetProfileUseCase getProfileUseCase;
  final LogoutUseCase logoutUseCase;

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await getProfileUseCase();
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> logout() async {
    await logoutUseCase();
    if (!isClosed) emit(ProfileLoggedOut());
  }
}
