import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/domain/repositories/admin_repository.dart';

class GetAdminUsersParams extends Equatable {
  final int page;
  final int limit;

  const GetAdminUsersParams({this.page = 1, this.limit = 100});

  @override
  List<Object?> get props => [page, limit];
}

class GetAdminUsersUseCase
    implements UsecaseWithParms<List<AdminUserEntity>, GetAdminUsersParams> {
  final IAdminRepository _repository;

  GetAdminUsersUseCase({required IAdminRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<AdminUserEntity>>> call(
    GetAdminUsersParams params,
  ) {
    return _repository.getUsers(page: params.page, limit: params.limit);
  }
}
