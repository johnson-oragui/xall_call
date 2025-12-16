import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? token;
  final String? error;
  final int? statusCode;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.token,
    this.error,
    this.statusCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      token: json['token'],
      error: json['error'] ?? json['message'],
      statusCode: json['statusCode'],
    );
  }

  factory UserModel.fromError(String error, {int? statusCode}) {
    return UserModel(
      id: '',
      email: '',
      username: '',
      error: error,
      statusCode: statusCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'token': token,
      'error': error,
      'statusCode': statusCode,
    };
  }

  bool get hasError => error != null;

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, email, username, token, error, statusCode];
}
