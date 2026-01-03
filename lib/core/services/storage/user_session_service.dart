import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';

  UserSessionService(this._prefs);

  /// Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String name,
  }) async {
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, name);
  }

  /// Logged in if userId exists
  bool hasSession() {
    return _prefs.containsKey(_keyUserId);
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserName);
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
  }
}
