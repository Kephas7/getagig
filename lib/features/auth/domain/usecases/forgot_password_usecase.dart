import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/data/repositories/auth_repository.dart';

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ForgotPasswordUsecase(authRepository: authRepository);
});

class ForgotPasswordParams extends Equatable {
  final String email;

  const ForgotPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordUsecase implements UsecaseWithParms<String, ForgotPasswordParams> {
  final IAuthRepository _authRepository;

  ForgotPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(ForgotPasswordParams params) {
    return _authRepository.forgotPassword(params.email);
  }
}
