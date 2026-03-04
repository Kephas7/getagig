import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';

class RemoveOrganizerVideoParams extends Equatable {
  final String videoUrl;

  const RemoveOrganizerVideoParams({required this.videoUrl});

  @override
  List<Object?> get props => [videoUrl];
}

final removeOrganizerVideoUseCaseProvider =
    Provider<RemoveOrganizerVideoUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return RemoveOrganizerVideoUseCase(repository: repository);
});

class RemoveOrganizerVideoUseCase
    implements UsecaseWithParms<OrganizerEntity, RemoveOrganizerVideoParams> {
  final IOrganizerRepository _repository;

  RemoveOrganizerVideoUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(
    RemoveOrganizerVideoParams params,
  ) {
    return _repository.removeVideo(params.videoUrl);
  }
}


