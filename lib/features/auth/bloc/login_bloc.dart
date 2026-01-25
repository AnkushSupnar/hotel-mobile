import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/services/api_config_service.dart';
import 'package:hotel/core/services/auth_storage_service.dart';
import 'package:hotel/features/auth/bloc/login_event.dart';
import 'package:hotel/features/auth/bloc/login_state.dart';
import 'package:hotel/features/auth/data/models/user_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ApiClient _apiClient;

  LoginBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginReset>(_onReset);
    on<LoadUsernames>(_onLoadUsernames);
    on<ServerUrlChanged>(_onServerUrlChanged);
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

    try {
      // Call login API
      final response = await _apiClient.post(
        'auth/login',
        body: {
          'username': state.username,
          'password': state.password,
        },
        includeAuth: false,
      );

      if (response.success && response.data != null) {
        // Extract token and user data from response
        final data = response.data!;

        // Check if data is nested under 'data' key or directly in response
        final userData = data['data'] as Map<String, dynamic>? ?? data;

        final token = userData['token'] as String?;
        final refreshToken = userData['refreshToken'] as String?;

        // Parse user model from response
        final user = UserModel.fromLoginResponse(userData);

        // Extract features list
        List<String> features = [];
        if (userData['features'] != null) {
          features = List<String>.from(userData['features'] as List);
        }

        // Store auth data
        if (token != null) {
          await AuthStorageService.saveAuthData(
            token: token,
            refreshToken: refreshToken,
            userId: user.userId,
            employeeId: user.employeeId,
            username: user.username,
            employeeName: user.employeeName,
            role: user.role,
            features: features,
            tokenExpiresAt: user.tokenExpiresAt,
          );
        }

        emit(state.copyWith(
          status: LoginStatus.success,
          role: user.role,
          employeeName: user.employeeName,
          userId: user.userId,
          employeeId: user.employeeId,
          features: features,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: response.message ?? 'Invalid username or password',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Connection error. Please try again.',
      ));
    }
  }

  void _onReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginState());
  }

  Future<void> _onLoadUsernames(
    LoadUsernames event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(usernamesStatus: UsernamesStatus.loading));

    try {
      final response = await _apiClient.get(
        'auth/usernames',
        includeAuth: false,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        List<String> usernames = [];

        // Handle different response formats
        if (data.containsKey('usernames')) {
          usernames = List<String>.from(data['usernames'] as List);
        } else if (data.containsKey('data')) {
          usernames = List<String>.from(data['data'] as List);
        }

        emit(state.copyWith(
          usernames: usernames,
          usernamesStatus: UsernamesStatus.loaded,
          usernamesError: null,
        ));
      } else {
        emit(state.copyWith(
          usernamesStatus: UsernamesStatus.error,
          usernamesError: response.message ?? 'Failed to load usernames',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        usernamesStatus: UsernamesStatus.error,
        usernamesError: 'Connection error. Check server URL.',
      ));
    }
  }

  Future<void> _onServerUrlChanged(
    ServerUrlChanged event,
    Emitter<LoginState> emit,
  ) async {
    await ApiConfigService.setServerUrl(event.serverUrl);
    // Reload usernames after server URL change
    add(const LoadUsernames());
  }
}
