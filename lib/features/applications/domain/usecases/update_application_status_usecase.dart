import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/domain/repositories/application_repository.dart';

class UpdateApplicationStatusUseCase {
  final IApplicationRepository repository;

  UpdateApplicationStatusUseCase({required this.repository});

  Future<Either<Failure, bool>> call(String applicationId, String status) {
    return repository.updateStatus(applicationId, status);
  }
}
