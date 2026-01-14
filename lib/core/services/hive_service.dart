import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/auth/data/models/auth_hive_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  /// Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';

    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // ─────────────────────────────────────────────
  // AUTH METHODS
  // ─────────────────────────────────────────────

  /// Register new user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.userId, user);
    return user;
  }

  /// Login user by email & password
  AuthHiveModel? login(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (u) => u.email == email && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get user by ID (used for session restore)
  AuthHiveModel? getUserById(String userId) {
    return _authBox.get(userId);
  }

  /// Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  /// Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (!_authBox.containsKey(user.userId)) return false;

    await _authBox.put(user.userId, user);
    return true;
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _authBox.delete(userId);
  }

  /// Logout handled by UserSessionService (NOT Hive)
  Future<void> logout() async {
    // intentionally empty
  }
}
