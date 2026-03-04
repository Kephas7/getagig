import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity user);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, String>> forgotPassword(String email);
  Future<Either<Failure, String>> resetPassword(String token, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
}
