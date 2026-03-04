import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';
import 'package:getagig/core/error/failures.dart';
import '../entities/organizer_entity.dart';

final getOrganizerProfileByIdUseCaseProvider =
    Provider<GetOrganizerProfileByIdUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return GetOrganizerProfileByIdUseCase(repository: repository);
});

class GetOrganizerProfileByIdUseCase
    implements UsecaseWithParms<OrganizerEntity, String> {
  final IOrganizerRepository _repository;

  GetOrganizerProfileByIdUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(String id) {
    return _repository.getProfileById(id);
  }
}


