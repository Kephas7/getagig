import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository_impl.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';
import '../entities/organizer_entity.dart';

class CreateOrganizerProfileParams extends Equatable {
  final String organizationName;
  final String? bio;
  final String contactPerson;
  final String phone;
  final String email;
  final String city;
  final String state;
  final String country;
  final String organizationType;
  final List<String> eventTypes;
  final String? website;

  const CreateOrganizerProfileParams({
    required this.organizationName,
    this.bio,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.city,
    required this.state,
    required this.country,
    required this.organizationType,
    required this.eventTypes,
    this.website,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'organizationName': organizationName,
      'bio': bio ?? '',
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'location': {
        'city': city,
        'state': state,
        'country': country,
      },
      'organizationType': organizationType,
      'eventTypes': eventTypes,
    };

    if (website != null && website!.isNotEmpty) {
      data['website'] = website;
    }

    return data;
  }

  @override
  List<Object?> get props => [
        organizationName,
        bio,
        contactPerson,
        phone,
        email,
        city,
        state,
        country,
        organizationType,
        eventTypes,
        website,
      ];
}

final createOrganizerProfileUseCaseProvider =
    Provider<CreateOrganizerProfileUseCase>((ref) {
  final repository = ref.read(organizerRepositoryProvider);
  return CreateOrganizerProfileUseCase(repository: repository);
});

class CreateOrganizerProfileUseCase
    implements UsecaseWithParms<OrganizerEntity, CreateOrganizerProfileParams> {
  final IOrganizerRepository _repository;

  CreateOrganizerProfileUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(
    CreateOrganizerProfileParams params,
  ) {
    return _repository.createProfile(params.toJson());
  }
}

