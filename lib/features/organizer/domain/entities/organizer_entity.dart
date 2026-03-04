import 'package:equatable/equatable.dart';

class OrganizerEntity extends Equatable {
  final String id;
  final String userId;
  final String organizationName;
  final String? profilePicture;
  final String? bio;
  final String contactPerson;
  final String phone;
  final String email;
  final String location;
  final String organizationType;
  final List<String> eventTypes;
  final List<String> verificationDocuments;
  final String? website;
  final List<String> photos;
  final List<String> videos;
  final bool isVerified;
  final bool verificationRequested;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const OrganizerEntity({
    required this.id,
    required this.userId,
    required this.organizationName,
    this.profilePicture,
    this.bio,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.location,
    required this.organizationType,
    required this.eventTypes,
    required this.verificationDocuments,
    this.website,
    required this.photos,
    required this.videos,
    required this.isVerified,
    required this.verificationRequested,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    organizationName,
    profilePicture,
    bio,
    contactPerson,
    phone,
    email,
    location,
    organizationType,
    eventTypes,
    verificationDocuments,
    website,
    photos,
    videos,
    isVerified,
    verificationRequested,
    isActive,
    createdAt,
    updatedAt,
  ];
}
