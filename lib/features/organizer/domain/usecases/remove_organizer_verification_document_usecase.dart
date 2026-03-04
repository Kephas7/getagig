import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';

class RemoveOrganizerVerificationDocumentParams extends Equatable {
  final String documentUrl;

  const RemoveOrganizerVerificationDocumentParams({required this.documentUrl});

  @override
  List<Object?> get props => [documentUrl];
}

final removeOrganizerVerificationDocumentUseCaseProvider =
    Provider<RemoveOrganizerVerificationDocumentUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return RemoveOrganizerVerificationDocumentUseCase(repository: repository);
});

class RemoveOrganizerVerificationDocumentUseCase
    implements
        UsecaseWithParms<OrganizerEntity,
            RemoveOrganizerVerificationDocumentParams> {
  final IOrganizerRepository _repository;

  RemoveOrganizerVerificationDocumentUseCase({
    required IOrganizerRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(
    RemoveOrganizerVerificationDocumentParams params,
  ) {
    return _repository.removeVerificationDocument(params.documentUrl);
  }
}


