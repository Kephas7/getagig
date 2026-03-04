import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';

abstract interface class IAdminRepository {
  Future<Either<Failure, AdminUserEntity>> createUser({
    required String username,
    required String email,
    required String password,
    required String role,
  });

  Future<Either<Failure, List<AdminUserEntity>>> getUsers({
    int page,
    int limit,
  });

  Future<Either<Failure, bool>> setVerificationStatus({
    required AdminUserEntity user,
    required bool isVerified,
    String? rejectionReason,
  });

  Future<Either<Failure, bool>> deleteUser(String userId);

  Future<Either<Failure, AdminUserEntity>> updateUser({
    required String userId,
    required String username,
    required String email,
    required String role,
    String? password,
  });
}
