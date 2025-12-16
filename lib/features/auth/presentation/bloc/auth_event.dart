import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;

  const SignUpRequested({
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [email, username, password, confirmPassword];
}

class SignOutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
