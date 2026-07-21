import 'package:flutter_dotenv/flutter_dotenv.dart';

// API Configuration

class APIConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
