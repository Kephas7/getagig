import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';

final addOrganizerVerificationDocumentsUseCaseProvider =
    Provider<AddOrganizerVerificationDocumentsUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return AddOrganizerVerificationDocumentsUseCase(repository: repository);
});

class AddOrganizerVerificationDocumentsUseCase
    implements UsecaseWithParms<OrganizerEntity, List<File>> {
  final IOrganizerRepository _repository;

  AddOrganizerVerificationDocumentsUseCase({
    required IOrganizerRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(List<File> files) {
    return _repository.addVerificationDocuments(files);
  }
}


