import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';
import 'package:getagig/features/auth/data/repositories/auth_repository.dart';

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUsecase implements UsecaseWithParms<AuthEntity, LoginParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failures, AuthEntity>> call(LoginParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
