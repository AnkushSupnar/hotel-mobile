import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginUsernameChanged extends LoginEvent {
  final String username;

  const LoginUsernameChanged(this.username);

  @override
  List<Object?> get props => [username];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginReset extends LoginEvent {
  const LoginReset();
}

class LoadUsernames extends LoginEvent {
  const LoadUsernames();
}

class ServerUrlChanged extends LoginEvent {
  final String serverUrl;

  const ServerUrlChanged(this.serverUrl);

  @override
  List<Object?> get props => [serverUrl];
}
