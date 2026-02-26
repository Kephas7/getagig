import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';
import 'package:getagig/core/error/failures.dart';
import '../entities/organizer_entity.dart';

final getOrganizerProfileUseCaseProvider = Provider<GetOrganizerProfileUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return GetOrganizerProfileUseCase(repository: repository);
});

class GetOrganizerProfileUseCase implements UsecaseWithoutParms<OrganizerEntity> {
  final IOrganizerRepository _repository;

  GetOrganizerProfileUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call() {
    return _repository.getProfile();
  }
}

