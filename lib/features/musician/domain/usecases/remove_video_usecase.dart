import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

class RemoveVideoParams extends Equatable {
  final String videoUrl;

  const RemoveVideoParams({required this.videoUrl});

  @override
  List<Object?> get props => [videoUrl];
}

final removeVideoUseCaseProvider = Provider<RemoveVideoUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return RemoveVideoUseCase(repository: repository);
});

class RemoveVideoUseCase
    implements UsecaseWithParms<MusicianEntity, RemoveVideoParams> {
  final IMusicianRepository _repository;

  RemoveVideoUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(RemoveVideoParams params) {
    return _repository.removeVideo(params.videoUrl);
  }
}
