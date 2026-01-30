import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/musician/data/musicain_repository.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import '../entities/musician_entity.dart';

class UpdateProfileParams extends Equatable {
  final String? stageName;
  final String? bio;
  final String? phone;
  final String? city;
  final String? state;
  final String? country;
  final List<String>? genres;
  final List<String>? instruments;
  final int? experienceYears;
  final double? hourlyRate;
  final bool? isAvailable;

  const UpdateProfileParams({
    this.stageName,
    this.bio,
    this.phone,
    this.city,
    this.state,
    this.country,
    this.genres,
    this.instruments,
    this.experienceYears,
    this.hourlyRate,
    this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (stageName != null) data['stageName'] = stageName;
    if (bio != null) data['bio'] = bio;
    if (phone != null) data['phone'] = phone;

    if (city != null || state != null || country != null) {
      data['location'] = {};
      if (city != null) data['location']['city'] = city;
      if (state != null) data['location']['state'] = state;
      if (country != null) data['location']['country'] = country;
    }

    if (genres != null) data['genres'] = genres;
    if (instruments != null) data['instruments'] = instruments;
    if (experienceYears != null) data['experienceYears'] = experienceYears;
    if (hourlyRate != null) data['hourlyRate'] = hourlyRate;
    if (isAvailable != null) data['isAvailable'] = isAvailable;

    return data;
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

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.read(musicianRepositoryProvider);
  return UpdateProfileUseCase(repository: repository);
});

class UpdateProfileUseCase
    implements UsecaseWithParms<MusicianEntity, UpdateProfileParams> {
  final IMusicianRepository _repository;

  UpdateProfileUseCase({required IMusicianRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failures, MusicianEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(params.toJson());
  }
}
