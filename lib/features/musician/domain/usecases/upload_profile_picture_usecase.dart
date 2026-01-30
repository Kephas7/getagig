import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

final uploadProfilePictureUseCaseProvider =
    Provider<UploadProfilePictureUseCase>((ref) {
      final repository = ref.read(musicianRepositoryProvider);
      return UploadProfilePictureUseCase(repository: repository);
    });

class UploadProfilePictureUseCase
    implements UsecaseWithParms<MusicianEntity, File> {
  final IMusicianRepository _repository;

  UploadProfilePictureUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(File file) {
    return _repository.uploadProfilePicture(file);
  }
}
