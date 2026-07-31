import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.signup(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState());
  }
}
