import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/signin_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signInUseCase.execute(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (e is AuthError) {
        emit(AuthUnauthenticated(error: e));
        return;
      } else {
        emit(AuthUnauthenticated(error: AuthError(e.toString())));
      }
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signUpUseCase.execute(
        event.email,
        event.username,
        event.password,
        event.confirmPassword,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (e is AuthError) {
        emit(AuthUnauthenticated(error: e));
        return;
      } else {
        emit(AuthUnauthenticated(error: AuthError(e.toString())));
      }
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final isAuthenticated = authRepository.isAuthenticated();
    if (isAuthenticated) {
      final user = authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        return;
      }
    }
    emit(AuthUnauthenticated());
  }
}
