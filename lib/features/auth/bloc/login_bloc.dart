import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/constants/app_constants.dart';
import 'package:hotel/features/auth/bloc/login_event.dart';
import 'package:hotel/features/auth/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginReset>(_onReset);
  }

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      username: event.username,
      status: LoginStatus.initial,
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      status: LoginStatus.initial,
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please select a username and enter password',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check credentials against hardcoded values
    final storedPassword = AppConstants.userCredentials[state.username];

    if (storedPassword != null && storedPassword == state.password) {
      emit(state.copyWith(status: LoginStatus.success));
    } else {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Invalid username or password',
      ));
    }
  }

  void _onReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginState());
  }
}
