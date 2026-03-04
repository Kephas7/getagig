import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/domain/repositories/admin_repository.dart';

class UpdateAdminUserParams extends Equatable {
  final String userId;
  final String username;
  final String email;
  final String role;
  final String? password;

  const UpdateAdminUserParams({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    this.password,
  });

  @override
  List<Object?> get props => [userId, username, email, role, password];
}

class UpdateAdminUserUseCase
    implements UsecaseWithParms<AdminUserEntity, UpdateAdminUserParams> {
  final IAdminRepository _repository;

  UpdateAdminUserUseCase({required IAdminRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AdminUserEntity>> call(UpdateAdminUserParams params) {
    return _repository.updateUser(
      userId: params.userId,
      username: params.username,
      email: params.email,
      role: params.role,
      password: params.password,
    );
  }
}
