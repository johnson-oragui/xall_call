import 'package:xall_call/core/config/environment.dart';
import 'package:xall_call/core/constants/app_constants.dart';

class ApiConfig {
  static String get baseUrl => AppEnvironment.apiBaseUrl;

  static String getSignInUrl() => '$baseUrl${AppConstants.signInEndpoint}';
  static String getSignUpUrl() => '$baseUrl${AppConstants.signUpEndpoint}';
  static String getSignOutUrl() => '$baseUrl${AppConstants.signOutEndpoint}';
  static String getRefreshTokenUrl() =>
      '$baseUrl${AppConstants.refreshTokenEndpoint}';
  static String getUserProfileUrl() =>
      '$baseUrl${AppConstants.userProfileEndpoint}';

  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      AppConstants.contentTypeHeader: AppConstants.contentTypeJson,
    };

    if (token != null && token.isNotEmpty) {
      headers[AppConstants.authorizationHeader] =
          '${AppConstants.bearerPrefix}$token';
    }

    return headers;
  }
}
