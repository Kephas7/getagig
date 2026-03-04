import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';

final uploadOrganizerProfilePictureUseCaseProvider =
    Provider<UploadOrganizerProfilePictureUseCase>((ref) {
      final repository = ref.read(organizerRepositoryProvider);
      return UploadOrganizerProfilePictureUseCase(repository: repository);
    });

class UploadOrganizerProfilePictureUseCase
    implements UsecaseWithParms<OrganizerEntity, File> {
  final IOrganizerRepository _repository;

  UploadOrganizerProfilePictureUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(File file) {
    return _repository.uploadProfilePicture(file);
  }
}


