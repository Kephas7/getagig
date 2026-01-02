import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/auth/data/models/auth_hive_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  AuthHiveModel? _currentUser; // Track logged-in user in memory

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

  Future<void> _close() async {
    await Hive.close();
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  /// Register new user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.userId, user);
    return user;
  }

  /// Login user by email & password
  AuthHiveModel? login(String email, String password) {
    try {
      final user = _authBox.values.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Get currently logged-in user
  AuthHiveModel? getCurrentUser() => _currentUser;

  /// Logout current user
  Future<void> logout() async {
    _currentUser = null;
  }

  /// Get user by ID
  AuthHiveModel? getUserById(String userId) => _authBox.get(userId);

  /// Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.userId)) {
      await _authBox.put(user.userId, user);
      if (_currentUser?.userId == user.userId) {
        _currentUser = user;
      }
      return true;
    }
    return false;
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _authBox.delete(userId);
    if (_currentUser?.userId == userId) {
      _currentUser = null;
    }
  }
}
