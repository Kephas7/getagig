import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musician_repository.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

final requestVerificationUseCaseProvider = Provider<RequestVerificationUseCase>(
  (ref) {
    final repository = ref.read(musicianRepositoryProvider);
    return RequestVerificationUseCase(repository: repository);
  },
);

class RequestVerificationUseCase
    implements UsecaseWithoutParms<MusicianEntity> {
  final IMusicianRepository _repository;

  RequestVerificationUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, MusicianEntity>> call() {
    return _repository.requestVerification();
  }
}
