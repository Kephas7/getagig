import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/data/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';

final deleteGigUseCaseProvider = Provider<DeleteGigUseCase>((ref) {
  return DeleteGigUseCase(repository: ref.read(gigRepositoryProvider));
});

class DeleteGigUseCase {
  final IGigRepository repository;

  DeleteGigUseCase({required this.repository});

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteGig(id);
  }
}
