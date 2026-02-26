import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/gig_repository.dart';
import '../../data/repositories/gig_repository.dart';
import 'package:getagig/core/error/failures.dart';

final applyToGigUseCaseProvider = Provider<ApplyToGigUseCase>((ref) {
  return ApplyToGigUseCase(repository: ref.read(gigRepositoryProvider));
});

class ApplyToGigUseCase {
  final IGigRepository repository;

  ApplyToGigUseCase({required this.repository});

  Future<Either<Failure, void>> call(String gigId, String coverLetter) async {
    return await repository.applyToGig(gigId, coverLetter);
  }
}

