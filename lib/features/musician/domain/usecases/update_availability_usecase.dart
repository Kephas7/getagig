import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

class UpdateAvailabilityParams extends Equatable {
  final bool isAvailable;

  const UpdateAvailabilityParams({required this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}

final updateAvailabilityUseCaseProvider = Provider<UpdateAvailabilityUseCase>((
  ref,
) {
  final repository = ref.read(musicianRepositoryProvider);
  return UpdateAvailabilityUseCase(repository: repository);
});

class UpdateAvailabilityUseCase
    implements UsecaseWithParms<MusicianEntity, UpdateAvailabilityParams> {
  final IMusicianRepository _repository;

  UpdateAvailabilityUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(
    UpdateAvailabilityParams params,
  ) {
    return _repository.updateAvailability(params.isAvailable);
  }
}
