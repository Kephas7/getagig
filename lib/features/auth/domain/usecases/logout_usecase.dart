import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/auth/data/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';

class LogoutUsecase implements UsecaseWithoutParams {
  final IAuthRepository _authRepository;

  LogoutUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;
  @override
  Future<Either<Failures, bool>> call() {
    return _authRepository.logout();
  }
}
