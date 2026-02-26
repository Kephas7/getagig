import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';

final updateOrganizerActiveStatusUseCaseProvider =
    Provider<UpdateOrganizerActiveStatusUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return UpdateOrganizerActiveStatusUseCase(repository: repository);
});

class UpdateOrganizerActiveStatusUseCase
    implements UsecaseWithParms<OrganizerEntity, bool> {
  final IOrganizerRepository _repository;

  UpdateOrganizerActiveStatusUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(bool isActive) {
    return _repository.updateActiveStatus(isActive);
  }
}


