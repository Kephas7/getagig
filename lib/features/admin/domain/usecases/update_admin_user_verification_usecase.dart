import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/admin/domain/entities/admin_user_entity.dart';
import 'package:getagig/features/admin/domain/repositories/admin_repository.dart';

class UpdateAdminUserVerificationParams extends Equatable {
  final AdminUserEntity user;
  final bool isVerified;
  final String? rejectionReason;

  const UpdateAdminUserVerificationParams({
    required this.user,
    required this.isVerified,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [user, isVerified, rejectionReason];
}

class UpdateAdminUserVerificationUseCase
    implements UsecaseWithParms<bool, UpdateAdminUserVerificationParams> {
  final IAdminRepository _repository;

  UpdateAdminUserVerificationUseCase({required IAdminRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(UpdateAdminUserVerificationParams params) {
    return _repository.setVerificationStatus(
      user: params.user,
      isVerified: params.isVerified,
      rejectionReason: params.rejectionReason,
    );
  }
}
