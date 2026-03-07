import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/domain/repositories/application_repository.dart';

class GetMyApplicationsUseCase {
  final IApplicationRepository repository;

  GetMyApplicationsUseCase({required this.repository});

  Future<Either<Failure, List<ApplicationEntity>>> call() {
    return repository.getMyApplications();
  }
}
