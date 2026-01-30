import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

final addVideosUseCaseProvider = Provider<AddVideosUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return AddVideosUseCase(repository: repository);
});

class AddVideosUseCase implements UsecaseWithParms<MusicianEntity, List<File>> {
  final IMusicianRepository _repository;

  AddVideosUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(List<File> files) {
    return _repository.addVideos(files);
  }
}
