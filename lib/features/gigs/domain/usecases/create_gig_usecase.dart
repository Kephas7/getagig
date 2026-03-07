import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/data/repositories/gig_repository.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';

final createGigUseCaseProvider = Provider<CreateGigUseCase>((ref) {
  return CreateGigUseCase(repository: ref.read(gigRepositoryProvider));
});

class CreateGigUseCase {
  final IGigRepository repository;

  CreateGigUseCase({required this.repository});

  Future<Either<Failure, GigEntity>> call(Map<String, dynamic> data) {
    return repository.createGig(data);
  }
}
