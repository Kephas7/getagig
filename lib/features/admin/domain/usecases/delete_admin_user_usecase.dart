import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/admin/domain/repositories/admin_repository.dart';

class DeleteAdminUserParams extends Equatable {
  final String userId;

  const DeleteAdminUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteAdminUserUseCase
    implements UsecaseWithParms<bool, DeleteAdminUserParams> {
  final IAdminRepository _repository;

  DeleteAdminUserUseCase({required IAdminRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteAdminUserParams params) {
    return _repository.deleteUser(params.userId);
  }
}
