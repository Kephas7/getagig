import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/usecases/app_usecase.dart';
import 'package:getagig/features/organizer/data/repositories/organizer_repository.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';
import '../entities/organizer_entity.dart';

class UpdateOrganizerProfileParams extends Equatable {
  final String? organizationName;
  final String? bio;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? location;
  final String? organizationType;
  final List<String>? eventTypes;
  final String? website;

  const UpdateOrganizerProfileParams({
    this.organizationName,
    this.bio,
    this.contactPerson,
    this.phone,
    this.email,
    this.location,
    this.organizationType,
    this.eventTypes,
    this.website,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (organizationName != null) data['organizationName'] = organizationName;
    if (bio != null) data['bio'] = bio;
    if (contactPerson != null) data['contactPerson'] = contactPerson;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (location != null) data['location'] = location;

    if (organizationType != null) data['organizationType'] = organizationType;
    if (eventTypes != null) data['eventTypes'] = eventTypes;
    if (website != null) data['website'] = website;

    return data;
  }

  @override
  List<Object?> get props => [
    organizationName,
    bio,
    contactPerson,
    phone,
    email,
    location,
    organizationType,
    eventTypes,
    website,
  ];
}

final updateOrganizerProfileUseCaseProvider =
    Provider<UpdateOrganizerProfileUseCase>((ref) {
      final repository = ref.read(organizerRepositoryProvider);
      return UpdateOrganizerProfileUseCase(repository: repository);
    });

class UpdateOrganizerProfileUseCase
    implements UsecaseWithParms<OrganizerEntity, UpdateOrganizerProfileParams> {
  final IOrganizerRepository _repository;

  UpdateOrganizerProfileUseCase({required IOrganizerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrganizerEntity>> call(
    UpdateOrganizerProfileParams params,
  ) {
    return _repository.updateProfile(params.toJson());
  }
}
