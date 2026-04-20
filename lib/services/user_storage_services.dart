import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const String _keyUid = 'user_uid';
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyLevel = 'user_level';

  // Save User Data
  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUid, uid);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyLevel, level);
  }

  // Get User Data as a Map or Model
  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return  {
      'uid': prefs.getString(_keyUid) ?? '',
      'name': prefs.getString(_keyName) ?? 'Guest',
      'email': prefs.getString(_keyEmail) ?? '',
      'level': prefs.getString(_keyLevel) ?? 'A1',
    };
  }

  // Clear data on Logout
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}