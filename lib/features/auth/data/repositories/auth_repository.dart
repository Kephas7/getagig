import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/services/connectivity/network_info.dart';
import 'package:getagig/features/auth/data/datasources/auth_datasource.dart';
import 'package:getagig/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:getagig/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';
import 'package:getagig/features/auth/data/models/auth_hive_model.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    authLocalDataSource: authLocalDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;
  final _secureStorage = const FlutterSecureStorage();

  AuthRepository({
    required IAuthLocalDataSource authLocalDataSource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _authLocalDataSource = authLocalDataSource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

  // ================= LOGIN =================
  @override
  Future<Either<Failures, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          await _secureStorage.write(key: 'auth_token', value: apiModel.token);
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid credentials."));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['messsage'] ?? 'Login failed.',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authLocalDataSource.login(email, password);

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
  }

  // ================= REGISTER =================
  @override
  Future<Either<Failures, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['messsage'] ?? 'Registeration failed.',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        // Check duplicate email
        final existingUser = await _authLocalDataSource.getUserByEmail(
          user.email,
        );
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

        await _authLocalDataSource.register(authModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // ================= CURRENT USER =================
  @override
  Future<Either<Failures, AuthEntity>> getCurrentUser() async {
    // 🌐 ONLINE
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.getCurrentUser();

        if (apiModel == null) {
          return const Left(ApiFailure(message: "User not authenticated."));
        }

        return Right(apiModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to fetch user.',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    // 📦 OFFLINE (LOCAL)
    try {
      final localModel = await _authLocalDataSource.getCurrentUser();

      if (localModel == null) {
        return const Left(LocalDatabaseFailure(message: "No user logged in."));
      }

      return Right(localModel.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ================= LOGOUT =================
  @override
  Future<Either<Failures, bool>> logout() async {
    try {
      final result = await _authLocalDataSource.logout();
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
