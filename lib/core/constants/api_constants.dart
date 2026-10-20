import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static final String cartoApiKey = dotenv.env['CARTO_API_KEY'] ?? '';
}
