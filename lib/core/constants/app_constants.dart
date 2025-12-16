class AppConstants {
  static const String appName = 'Auth App';
  static const String baseUrl = 'http://localhost:8000/api';

  // API Endpoints
  static const String signInEndpoint = '/v1/authentication/login/';
  static const String signUpEndpoint = '/v1/authentication/register/';
  static const String signOutEndpoint = '/v1/authentication/logout/';
  static const String refreshTokenEndpoint = '/v1/authentication/refresh/';
  static const String userProfileEndpoint = '/v1/user/profile/';

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  static const String expiresAtKey = 'token_expires_at';

  // Validation messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String usernameRequired = 'Username is required';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength =
      'Password must be at least 8 characters';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordsDontMatch = 'Passwords do not match';
}
