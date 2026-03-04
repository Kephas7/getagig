import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';
import 'package:getagig/core/error/failures.dart';

final deleteOrganizerProfileUseCaseProvider =
    Provider<DeleteOrganizerProfileUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return DeleteOrganizerProfileUseCase(repository: repository);
});

class DeleteOrganizerProfileUseCase implements UsecaseWithoutParms<void> {
  final IOrganizerRepository _repository;

  DeleteOrganizerProfileUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call() {
    return _repository.deleteProfile();
  }
}


