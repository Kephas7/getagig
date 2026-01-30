import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import '../../../../core/error/failures.dart';

import '../entities/musician_entity.dart';

class CreateProfileParams extends Equatable {
  final String stageName;
  final String? bio;
  final String phone;
  final String city;
  final String state;
  final String country;
  final List<String> genres;
  final List<String> instruments;
  final int experienceYears;
  final double? hourlyRate;
  final bool? isAvailable;

  const CreateProfileParams({
    required this.stageName,
    this.bio,
    required this.phone,
    required this.city,
    required this.state,
    required this.country,
    required this.genres,
    required this.instruments,
    required this.experienceYears,
    this.hourlyRate,
    this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'stageName': stageName,
      if (bio != null) 'bio': bio,
      'phone': phone,
      'location': {'city': city, 'state': state, 'country': country},
      'genres': genres,
      'instruments': instruments,
      'experienceYears': experienceYears,
      if (hourlyRate != null) 'hourlyRate': hourlyRate,
      if (isAvailable != null) 'isAvailable': isAvailable,
    };
  }

  @override
  List<Object?> get props => [
    stageName,
    bio,
    phone,
    city,
    state,
    country,
    genres,
    instruments,
    experienceYears,
    hourlyRate,
    isAvailable,
  ];
}

final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return CreateProfileUseCase(repository: repository);
});

class CreateProfileUseCase
    implements UsecaseWithParms<MusicianEntity, CreateProfileParams> {
  final IMusicianRepository _repository;

  CreateProfileUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(CreateProfileParams params) {
    return _repository.createProfile(params.toJson());
  }
}
