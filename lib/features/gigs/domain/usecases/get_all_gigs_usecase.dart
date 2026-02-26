import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/gig_entity.dart';
import '../repositories/gig_repository.dart';
import '../../data/repositories/gig_repository.dart';
import 'package:getagig/core/error/failures.dart';

final getAllGigsUseCaseProvider = Provider<GetAllGigsUseCase>((ref) {
  return GetAllGigsUseCase(repository: ref.read(gigRepositoryProvider));
});

class GetAllGigsUseCase {
  final IGigRepository repository;

  GetAllGigsUseCase({required this.repository});

  Future<Either<Failure, List<GigEntity>>> call() async {
    return await repository.getAllGigs();
  }
}

