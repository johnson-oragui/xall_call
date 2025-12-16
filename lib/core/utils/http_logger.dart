import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpLogger {
  static void logRequest(http.BaseRequest request) {
    debugPrint(
      '[REQUEST] ${request.method}, [PATH] ${request.url}, [HEADERS] ${request.headers}',
    );

    if (request is http.Request) {
      debugPrint('Body: ${request.body}');
    }
  }

  static void logResponse(http.Response response) {
    debugPrint('[RESPONSE] ${response.statusCode} ${response.request?.url}');
    debugPrint('Headers: ${response.headers}');
    debugPrint('Body: ${response.body}');
  }

  static void logError(dynamic error) {
    debugPrint('[ERROR] $error');
  }
}
