import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/data/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';

final updateGigUseCaseProvider = Provider<UpdateGigUseCase>((ref) {
  return UpdateGigUseCase(repository: ref.read(gigRepositoryProvider));
});

class UpdateGigUseCase {
  final IGigRepository repository;

  UpdateGigUseCase({required this.repository});

  Future<Either<Failure, GigEntity>> call(
    String id,
    Map<String, dynamic> data,
  ) {
    return repository.updateGig(id, data);
  }
}
