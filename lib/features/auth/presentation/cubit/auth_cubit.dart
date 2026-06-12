import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_login_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckLoginUseCase checkLoginUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkLoginUseCase,
    required this.authRepository,
  }) : super(AuthInitial());

  Future<void> appStarted() async {
    emit(AuthLoading());
    final result = await checkLoginUseCase();
    await result.fold(
      (failure) async {
        emit(AuthUnauthenticated());
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await authRepository.getCachedUser();
          userResult.fold(
            (failure) => emit(AuthUnauthenticated()),
            (user) => emit(AuthAuthenticated(user)),
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: email, password: password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }
}
