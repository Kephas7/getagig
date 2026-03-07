import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';

abstract interface class IApplicationRepository {
  Future<Either<Failure, List<ApplicationEntity>>> getMyApplications();
  Future<Either<Failure, List<ApplicationEntity>>> getGigApplications(
    String gigId,
  );
  Future<Either<Failure, ApplicationEntity>> apply(
    String gigId,
    String coverLetter,
  );
  Future<Either<Failure, bool>> updateStatus(
    String applicationId,
    String status,
  );
}
