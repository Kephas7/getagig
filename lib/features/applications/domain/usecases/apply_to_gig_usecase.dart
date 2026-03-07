import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/applications/domain/repositories/application_repository.dart';

class ApplyToGigUseCase {
  final IApplicationRepository repository;

  ApplyToGigUseCase({required this.repository});

  Future<Either<Failure, void>> call(String gigId, String coverLetter) async {
    final result = await repository.apply(gigId, coverLetter);
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
