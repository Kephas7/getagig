import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/auth/data/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUsecase(authRepository: authRepository);
});

class LogoutUsecase implements UsecaseWithoutParms {
  final IAuthRepository _authRepository;

  LogoutUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;
  @override
  Future<Either<Failures, bool>> call() {
    return _authRepository.logout();
  }
}
