import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/data/datasources/auth_datasource.dart';
import 'package:getagig/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:getagig/features/auth/data/models/auth_hive_model.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  return AuthRepository(authDataSource: authDatasource);
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource;

  AuthRepository({required IAuthLocalDataSource authDataSource})
    : _authDataSource = authDataSource;

  // ================= LOGIN =================
  @override
  Future<Either<Failures, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final model = await _authDataSource.login(email, password);

      if (model == null) {
        return const Left(
          LocalDatabaseFailure(message: "Invalid email or password."),
        );
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ================= REGISTER =================
  @override
  Future<Either<Failures, bool>> register(AuthEntity user) async {
    try {
      // Check duplicate email
      final existingUser = await _authDataSource.getUserByEmail(user.email);
      if (existingUser != null) {
        return const Left(
          LocalDatabaseFailure(message: "Email already registered."),
        );
      }

      final userId = const Uuid().v4();

      final authModel = AuthHiveModel(
        userId: userId,
        username: user.username,
        email: user.email,
        password: user.password!,
        role: user.role.isEmpty ? 'musician' : user.role,
      );

      await _authDataSource.register(authModel);
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ================= CURRENT USER =================
  @override
  Future<Either<Failures, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();

      if (model == null) {
        return const Left(LocalDatabaseFailure(message: "No user logged in."));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ================= LOGOUT =================
  @override
  Future<Either<Failures, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
