import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import '../../../../core/error/failures.dart';
import '../entities/musician_entity.dart';

class GetProfileByIdParams extends Equatable {
  final String id;

  const GetProfileByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}

final getProfileByIdUseCaseProvider = Provider<GetProfileByIdUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return GetProfileByIdUseCase(repository: repository);
});

class GetProfileByIdUseCase
    implements UsecaseWithParms<MusicianEntity, GetProfileByIdParams> {
  final IMusicianRepository _repository;

  GetProfileByIdUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(GetProfileByIdParams params) {
    return _repository.getProfileById(params.id);
  }
}
