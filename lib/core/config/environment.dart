import 'package:flutter/foundation.dart';
import 'package:xall_call/core/config/env_config.dart';

enum Environment { development, staging, production }

class AppEnvironment {
  static Environment _currentEnvironment = Environment.development;

  static String _apiBaseUrl = "";

  static Environment get current => _currentEnvironment;
  static String get apiBaseUrl => _apiBaseUrl;

  static void initialize(Environment env) {
    _currentEnvironment = env;

    switch (env) {
      case Environment.development:
        _apiBaseUrl = EnvConfig.baseUrl;

        break;
      case Environment.staging:
        _apiBaseUrl = EnvConfig.baseUrl;
        break;
      case Environment.production:
        // _apiBaseUrl = 'https://api.render.com/api';
        _apiBaseUrl = EnvConfig.baseUrl;
        break;
    }

    if (kDebugMode) {
      debugPrint('Environment: $_currentEnvironment');
      debugPrint('API Base URL: $_apiBaseUrl');
    }
  }
}
