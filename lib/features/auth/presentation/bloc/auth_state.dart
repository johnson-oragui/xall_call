import 'package:equatable/equatable.dart';
import 'package:xall_call/features/auth/domain/entities/user_entity.dart';

class AuthError {
  final String message;
  final int? statusCode;
  final dynamic data;

  AuthError(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final AuthError? error;
  // final String? error;

  const AuthUnauthenticated({this.error});

  String get errorMessage => error?.message ?? '';
  int? get errorStatusCode => error?.statusCode;

  @override
  List<Object> get props => [error ?? AuthError('')];
}
