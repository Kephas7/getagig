import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';

final requestOrganizerVerificationUseCaseProvider =
    Provider<RequestOrganizerVerificationUseCase>((ref) {
      final repository = ref.read(organizerRepositoryProvider);
      return RequestOrganizerVerificationUseCase(repository: repository);
    });

class RequestOrganizerVerificationUseCase
    implements UsecaseWithoutParms<OrganizerEntity> {
  final IOrganizerRepository _repository;

  RequestOrganizerVerificationUseCase({
    required IOrganizerRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call() {
    return _repository.requestVerification();
  }
}
