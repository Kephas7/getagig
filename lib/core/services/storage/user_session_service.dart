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

  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'email';
  static const String _keyUserName = 'username';
  static const String _keyUserRole = 'role';

  UserSessionService(this._prefs);

  /// Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
    required String role,
  }) async {
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, username);
    await _prefs.setString(_keyUserRole, role);
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

  String? getCurrentUserRole() {
    return _prefs.getString(_keyUserRole);
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserRole);
  }
}
