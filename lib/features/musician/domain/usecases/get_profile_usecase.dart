import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musician_repository.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import 'package:getagig/core/error/failures.dart';
import '../entities/musician_entity.dart';

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return GetProfileUseCase(repository: repository);
});

class GetProfileUseCase implements UsecaseWithoutParms<MusicianEntity> {
  final IMusicianRepository _repository;

  GetProfileUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, MusicianEntity>> call() {
    return _repository.getProfile();
  }
}

