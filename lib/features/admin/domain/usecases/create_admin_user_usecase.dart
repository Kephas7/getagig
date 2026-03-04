import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/domain/repositories/admin_repository.dart';

class CreateAdminUserParams extends Equatable {
  final String username;
  final String email;
  final String password;
  final String role;

  const CreateAdminUserParams({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [username, email, password, role];
}

class CreateAdminUserUseCase
    implements UsecaseWithParms<AdminUserEntity, CreateAdminUserParams> {
  final IAdminRepository _repository;

  CreateAdminUserUseCase({required IAdminRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AdminUserEntity>> call(CreateAdminUserParams params) {
    return _repository.createUser(
      username: params.username,
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}
