import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl => dotenv.get('BASE_URL');
  static String get apiKey => dotenv.get('API_KEY');
  static String get environment => dotenv.get('ENVIRONMENT');

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
