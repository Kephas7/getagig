import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

final deleteProfileUseCaseProvider = Provider<DeleteProfileUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return DeleteProfileUseCase(repository: repository);
});

class DeleteProfileUseCase implements UsecaseWithoutParms<void> {
  final IMusicianRepository _repository;

  DeleteProfileUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, void>> call() {
    return _repository.deleteProfile();
  }
}
