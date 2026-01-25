import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:getagig/features/auth/data/datasources/auth_datasource.dart';
import 'package:getagig/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<IAuthLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    return await _hiveService.register(user);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = _hiveService.login(email, password);

      if (user == null) return null;

      await _userSessionService.saveUserSession(
        userId: user.userId,
        email: user.email,
        username: user.username,
        role: user.role ?? 'musician',
      );

      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) return null;

      return _hiveService.getUserById(userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearSession();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    return _hiveService.getUserById(authId);
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    return _hiveService.getUserByEmail(email);
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    return await _hiveService.updateUser(user);
  }

  @override
  Future<bool> deleteUser(String authId) async {
    await _hiveService.deleteUser(authId);
    return true;
  }
}
