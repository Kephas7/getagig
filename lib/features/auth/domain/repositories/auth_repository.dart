import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failures, bool>> register(AuthEntity user);
  Future<Either<Failures, AuthEntity>> login(String email, String password);
  Future<Either<Failures, AuthEntity>> getCurrentUser();
  Future<Either<Failures, bool>> logout();
}
