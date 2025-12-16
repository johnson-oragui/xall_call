import 'dart:convert';
import 'package:xall_call/core/constants/app_constants.dart';
import 'package:universal_html/html.dart' as html;

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      return await remoteDataSource.signIn(email, password);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserEntity> signUp(
    String email,
    String username,
    String password,
    String confirmPassword,
  ) async {
    try {
      return await remoteDataSource.signUp(
        email,
        username,
        password,
        confirmPassword,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  bool isAuthenticated() {
    final token = html.window.localStorage[AppConstants.tokenKey];
    return token != null;
  }

  @override
  UserEntity? getCurrentUser() {
    final userJson = html.window.localStorage[AppConstants.userKey];

    if (userJson != null) {
      final userMap = json.decode(userJson);
      return UserEntity(
        id: userMap['id'],
        email: userMap['email'],
        username: userMap['username'],
      );
    }

    return null;
  }
}
