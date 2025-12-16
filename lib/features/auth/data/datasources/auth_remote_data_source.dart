import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:xall_call/core/config/api_config.dart';
import 'package:xall_call/core/constants/app_constants.dart';
import 'package:xall_call/core/utils/http_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(
    String email,
    String username,
    String password,
    String confirmPassword,
  );
  Future<void> signOut();
  Future<UserEntity?> refreshToken(String refreshToken);
  Future<bool> validateToken(String token);
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode = 500, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      final url = ApiConfig.getSignInUrl();
      HttpLogger.logRequest(http.Request('post', Uri.parse(url)));

      final response = await client
          .post(
            Uri.parse(url),
            // headers: ApiConfig.getHeaders(),
            body: {'email': email.toLowerCase(), 'password': password},
          )
          .timeout(AppConstants.connectTimeout);

      HttpLogger.logResponse(response);

      final Map<String, dynamic> responseData = json.decode(response.body);
      switch (response.statusCode) {
        case 200:
          final Map<String, dynamic> userData = responseData['data'];
          userData['token'] = responseData['data']['tokens']['auth'];

          UserModel userModel = UserModel.fromJson(userData);

          if (userModel.token != null) {
            _storeToken(userModel.token as String);
          }
          final UserEntity userEntity = UserEntity(
            email: userModel.email,
            id: userModel.id,
            username: userModel.username,
          );
          _storeUser(userModel);
          debugPrint('signin responseData: $responseData');

          return userEntity;
        case 401:
          debugPrint("signin 401 error");
          throw ApiException(
            'Invalid email or password',
            statusCode: 401,
            data: responseData,
          );
        case 422:
          debugPrint("signin 422 error");
          final errorMessage = _extractValidationErrors(responseData);
          throw ApiException(errorMessage, statusCode: 422, data: responseData);
        case 400:
          debugPrint("signin 400 error");
          throw ApiException(
            'Bade Request',
            statusCode: 400,
            data: responseData,
          );
        case 500:
          debugPrint("signin 500 error");
          throw ApiException(
            'Internal server error',
            statusCode: 500,
            data: responseData,
          );
        default:
          throw ApiException(
            responseData['message'] ?? 'Server error: ${response.statusCode}',
            statusCode: response.statusCode,
            data: responseData,
          );
      }
    } on http.ClientException catch (e) {
      debugPrint("ClientException: error signin in user: $e");
      // Network errors
      throw ApiException('Network error: ${e.message}', statusCode: 0);
    } on FormatException catch (e) {
      debugPrint("FormatException: error signin in user: $e");
      // JSON parsing errors
      throw ApiException(
        'Invalid server response: ${e.message}',
        statusCode: 500,
      );
    } catch (e) {
      debugPrint("error signin in user: $e");
      if (e is ApiException) rethrow;
      throw ApiException(e.toString(), statusCode: 500);
    }
  }

  @override
  Future<UserEntity> signUp(
    String email,
    String username,
    String password,
    String confirmPassword,
  ) async {
    String uri = ApiConfig.getSignUpUrl();
    try {
      final response = await client
          .post(
            Uri.parse(uri),
            headers: ApiConfig.getHeaders(),
            body: json.encode({
              'email': email.toLowerCase(),
              'password': password,
              'username': username,
              'password_confirm': confirmPassword,
            }),
          )
          .timeout(AppConstants.connectTimeout);
      if ([201, 200].contains(response.statusCode)) {
        Map<String, dynamic> responseData = json.decode(response.body);
        UserEntity userEntity = UserEntity(
          id: responseData['data']['id'],
          email: responseData['data']['email'],
          username: responseData['data']['username'],
        );

        return userEntity;
      } else if (response.statusCode == 409) {
        throw Exception('User with this email or username already exists');
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Validation error');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error signinup user: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Get current token
      final token = getToken();

      if (token != null) {
        final url = ApiConfig.getSignOutUrl();

        await client
            .post(Uri.parse(url), headers: ApiConfig.getHeaders(token: token))
            .timeout(AppConstants.connectTimeout);
      }
    } catch (e) {
      // Log error but continue with local signout
      if (kDebugMode) {
        debugPrint('Sign out API error (proceeding with local signout): $e');
      }
    } finally {
      _clearStorage(AppConstants.tokenKey, AppConstants.userKey);
    }
  }

  @override
  Future<UserEntity?> refreshToken(String refreshToken) async {
    try {
      final url = ApiConfig.getRefreshTokenUrl();

      final response = await client
          .post(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(),
            body: json.encode({'refreshToken': refreshToken}),
          )
          .timeout(AppConstants.connectTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          final user = UserModel.fromJson(userData);

          if (user.token != null) {
            _storeUser(user);
          }

          return user as UserEntity;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
      return null;
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      final url = ApiConfig.getUserProfileUrl();

      final response = await client
          .get(Uri.parse(url), headers: ApiConfig.getHeaders(token: token))
          .timeout(AppConstants.connectTimeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _storeUser(UserModel user) {
    try {
      Map<String, dynamic> userJson = user.toJson();
      userJson.remove('token');
      userJson.remove('error');
      userJson.remove('statusCode');
      html.window.localStorage[AppConstants.userKey] = json.encode(userJson);
    } catch (e) {
      debugPrint('Error storing user: $e');
    }
  }

  void _clearStorage(String? tokenKey, String? userKey) {
    try {
      if (tokenKey != null) {
        html.window.localStorage.remove(tokenKey);
      }
      if (userKey != null) {
        html.window.localStorage.remove(userKey);
      }
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }

  void _storeToken(String token) {
    try {
      html.window.localStorage[AppConstants.tokenKey] = token;
    } catch (e) {
      debugPrint('Error storing token: $e');
    }
  }

  String? getToken() {
    return html.window.localStorage[AppConstants.tokenKey];
  }

  String _extractValidationErrors(Map<String, dynamic> errorData) {
    try {
      if (errorData['errors'] != null && errorData['errors'] is Map) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        final errorMessages = errors.values
            .whereType<List>()
            .expand((list) => list)
            .whereType<String>()
            .toList();

        if (errorMessages.isNotEmpty) {
          return errorMessages.join(', ');
        }
      }

      return errorData['message'] ?? 'Validation error';
    } catch (e) {
      return 'Validation error';
    }
  }
}
