import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _secureStorage = const FlutterSecureStorage();

  UserSessionService(this._prefs);

  static const String _keyAuthToken = 'auth_token';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyBiometricEmail = 'biometric_email';
  static const String _keyBiometricPassword = 'biometric_password';
  static const String _keyCachedLoginEmail = 'cached_login_email';
  static const String _keyCachedLoginPassword = 'cached_login_password';

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
    required String role,
    String? token,
  }) async {
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, username);
    await _prefs.setString(_keyUserRole, role);
    // Persist the JWT so ApiClient interceptor can attach it to requests
    if (token != null && token.isNotEmpty) {
      await _secureStorage.write(key: _keyAuthToken, value: token);
    }
  }

  Future<String?> getToken() => _secureStorage.read(key: _keyAuthToken);

  Future<void> saveToken(String token) =>
      _secureStorage.write(key: _keyAuthToken, value: token);

  Future<void> enableBiometricLogin({
    required String email,
    required String password,
  }) async {
    await _prefs.setBool(_keyBiometricEnabled, true);
    await _secureStorage.write(key: _keyBiometricEmail, value: email);
    await _secureStorage.write(key: _keyBiometricPassword, value: password);
  }

  Future<void> cacheLoginCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _keyCachedLoginEmail, value: email);
    await _secureStorage.write(key: _keyCachedLoginPassword, value: password);
  }

  Future<BiometricCredentials?> getCachedLoginCredentials() async {
    final email = await _secureStorage.read(key: _keyCachedLoginEmail);
    final password = await _secureStorage.read(key: _keyCachedLoginPassword);
    if (email == null || password == null) {
      return null;
    }

    return BiometricCredentials(email: email, password: password);
  }

  Future<void> disableBiometricLogin() async {
    await _prefs.setBool(_keyBiometricEnabled, false);
    await _secureStorage.delete(key: _keyBiometricEmail);
    await _secureStorage.delete(key: _keyBiometricPassword);
  }

  Future<bool> isBiometricLoginEnabled() async {
    final enabled = _prefs.getBool(_keyBiometricEnabled) ?? false;
    if (!enabled) {
      return false;
    }

    final email = await _secureStorage.read(key: _keyBiometricEmail);
    final password = await _secureStorage.read(key: _keyBiometricPassword);

    if (email == null || password == null) {
      await _prefs.setBool(_keyBiometricEnabled, false);
      return false;
    }

    return true;
  }

  Future<BiometricCredentials?> getBiometricCredentials() async {
    final enabled = await isBiometricLoginEnabled();
    if (!enabled) {
      return null;
    }

    final email = await _secureStorage.read(key: _keyBiometricEmail);
    final password = await _secureStorage.read(key: _keyBiometricPassword);
    if (email == null || password == null) {
      return null;
    }

    return BiometricCredentials(email: email, password: password);
  }

  bool hasSession() {
    return _prefs.containsKey(_keyUserId);
  }

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

  Future<void> clearSession() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserRole);
    await _secureStorage.delete(key: _keyAuthToken);
    await _secureStorage.delete(key: _keyCachedLoginEmail);
    await _secureStorage.delete(key: _keyCachedLoginPassword);
  }
}

class BiometricCredentials {
  final String email;
  final String password;

  const BiometricCredentials({required this.email, required this.password});
}
