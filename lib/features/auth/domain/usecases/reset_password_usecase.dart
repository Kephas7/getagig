import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/data/repositories/auth_repository.dart';

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ResetPasswordUsecase(authRepository: authRepository);
});

class ResetPasswordParams extends Equatable {
  final String token;
  final String password;

  const ResetPasswordParams({required this.token, required this.password});

  @override
  List<Object?> get props => [token, password];
}

class ResetPasswordUsecase implements UsecaseWithParms<String, ResetPasswordParams> {
  final IAuthRepository _authRepository;

  ResetPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(ResetPasswordParams params) {
    return _authRepository.resetPassword(params.token, params.password);
  }
}
