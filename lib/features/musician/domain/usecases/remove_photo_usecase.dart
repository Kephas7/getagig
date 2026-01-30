import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

class RemovePhotoParams extends Equatable {
  final String photoUrl;

  const RemovePhotoParams({required this.photoUrl});

  @override
  List<Object?> get props => [photoUrl];
}

final removePhotoUseCaseProvider = Provider<RemovePhotoUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return RemovePhotoUseCase(repository: repository);
});

class RemovePhotoUseCase
    implements UsecaseWithParms<MusicianEntity, RemovePhotoParams> {
  final IMusicianRepository _repository;

  RemovePhotoUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(RemovePhotoParams params) {
    return _repository.removePhoto(params.photoUrl);
  }
}
