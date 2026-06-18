import 'package:flutter_dotenv/flutter_dotenv.dart';

// API Configuration
// Read your Gemini API key from .env file

class APIConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
