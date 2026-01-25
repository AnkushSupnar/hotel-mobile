import 'package:equatable/equatable.dart';
import 'package:hotel/features/auth/data/models/user_model.dart';

enum LoginStatus { initial, loading, success, failure }

enum UsernamesStatus { initial, loading, loaded, error }

class LoginState extends Equatable {
  final String username;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final List<String> usernames;
  final UsernamesStatus usernamesStatus;
  final String? usernamesError;
  final String? role;
  final String? employeeName;
  final int? userId;
  final int? employeeId;
  final List<String> features;
  final UserModel? user;

  const LoginState({
    this.username = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.usernames = const [],
    this.usernamesStatus = UsernamesStatus.initial,
    this.usernamesError,
    this.role,
    this.employeeName,
    this.userId,
    this.employeeId,
    this.features = const [],
    this.user,
  });

  LoginState copyWith({
    String? username,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    List<String>? usernames,
    UsernamesStatus? usernamesStatus,
    String? usernamesError,
    String? role,
    String? employeeName,
    int? userId,
    int? employeeId,
    List<String>? features,
    UserModel? user,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
      usernames: usernames ?? this.usernames,
      usernamesStatus: usernamesStatus ?? this.usernamesStatus,
      usernamesError: usernamesError,
      role: role ?? this.role,
      employeeName: employeeName ?? this.employeeName,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      features: features ?? this.features,
      user: user ?? this.user,
    );
  }

  bool get isValid => username.isNotEmpty && password.isNotEmpty;

  bool hasFeature(String feature) => features.contains(feature);

  @override
  List<Object?> get props => [
        username,
        password,
        status,
        errorMessage,
        usernames,
        usernamesStatus,
        usernamesError,
        role,
        employeeName,
        userId,
        employeeId,
        features,
        user,
      ];
}
