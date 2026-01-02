import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/auth/data/repositories/auth_repository.dart';
import 'package:getagig/features/auth/domain/entities/auth_entity.dart';
import 'package:getagig/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class RegisterUsecase implements UsecaseWithParms<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failures, bool>> call(RegisterParams params) {
    final authEntity = AuthEntity(
      name: params.name,
      email: params.email,
      password: params.password,
    );
    return _authRepository.register(authEntity);
  }
}
