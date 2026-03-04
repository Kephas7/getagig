import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/admin/data/datasources/admin_datasource.dart';
import 'package:getagig/features/admin/data/datasources/remote/admin_remote_datasource.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<IAdminRepository>((ref) {
  final remoteDataSource = ref.read(adminRemoteDataSourceProvider);
  return AdminRepository(remoteDataSource: remoteDataSource);
});

class AdminRepository implements IAdminRepository {
  final IAdminRemoteDataSource _remoteDataSource;

  AdminRepository({required IAdminRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, AdminUserEntity>> createUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final createdUser = await _remoteDataSource.createUser(
        username: username,
        email: email,
        password: password,
        role: role,
      );

      return Right(createdUser.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to create user'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminUserEntity>>> getUsers({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final users = await _remoteDataSource.getUsers(page: page, limit: limit);
      return Right(users.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to fetch users'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> setVerificationStatus({
    required AdminUserEntity user,
    required bool isVerified,
    String? rejectionReason,
  }) async {
    try {
      await _remoteDataSource.setVerificationStatus(
        userId: user.id,
        role: user.role,
        isVerified: isVerified,
        rejectionReason: rejectionReason,
      );
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to update verification status',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String userId) async {
    try {
      await _remoteDataSource.deleteUser(userId);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to delete user'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateUser({
    required String userId,
    required String username,
    required String email,
    required String role,
    String? password,
  }) async {
    try {
      final updatedUser = await _remoteDataSource.updateUser(
        userId: userId,
        username: username,
        email: email,
        role: role,
        password: password,
      );

      return Right(updatedUser.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to update user'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
