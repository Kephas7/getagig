import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/data/models/application_model.dart';

abstract interface class IApplicationRepository {
  Future<Either<Failure, List<ApplicationModel>>> getMyApplications();
  Future<Either<Failure, List<ApplicationModel>>> getGigApplications(String gigId);
  Future<Either<Failure, ApplicationModel>> apply(String gigId, String coverLetter);
  Future<Either<Failure, bool>> updateStatus(String applicationId, String status);
}

