import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';

class RemoveOrganizerPhotoParams extends Equatable {
  final String photoUrl;

  const RemoveOrganizerPhotoParams({required this.photoUrl});

  @override
  List<Object?> get props => [photoUrl];
}

final removeOrganizerPhotoUseCaseProvider =
    Provider<RemoveOrganizerPhotoUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return RemoveOrganizerPhotoUseCase(repository: repository);
});

class RemoveOrganizerPhotoUseCase
    implements UsecaseWithParms<OrganizerEntity, RemoveOrganizerPhotoParams> {
  final IOrganizerRepository _repository;

  RemoveOrganizerPhotoUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(
    RemoveOrganizerPhotoParams params,
  ) {
    return _repository.removePhoto(params.photoUrl);
  }
}


