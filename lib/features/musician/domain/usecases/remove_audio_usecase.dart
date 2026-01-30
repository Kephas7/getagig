import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

class RemoveAudioParams extends Equatable {
  final String audioUrl;

  const RemoveAudioParams({required this.audioUrl});

  @override
  List<Object?> get props => [audioUrl];
}

final removeAudioUseCaseProvider = Provider<RemoveAudioUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return RemoveAudioUseCase(repository: repository);
});

class RemoveAudioUseCase
    implements UsecaseWithParms<MusicianEntity, RemoveAudioParams> {
  final IMusicianRepository _repository;

  RemoveAudioUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(RemoveAudioParams params) {
    return _repository.removeAudio(params.audioUrl);
  }
}
