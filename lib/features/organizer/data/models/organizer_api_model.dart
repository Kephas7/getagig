import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/organizer_entity.dart';

part 'organizer_api_model.g.dart';

@JsonSerializable()
class OrganizerApiModel {
  final String id;
  final String userId;
  final String organizationName;
  final String? profilePicture;
  final String? bio;
  final String contactPerson;
  final String phone;
  final String email;
  final Map<String, dynamic> location;
  final String organizationType;
  final List<String> eventTypes;
  final List<String> verificationDocuments;
  final String? website;
  final List<String> photos;
  final List<String> videos;
  final bool isVerified;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  OrganizerApiModel({
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
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizerApiModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizerApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizerApiModelToJson(this);

  OrganizerEntity toEntity() {
    return OrganizerEntity(
      id: id,
      userId: userId,
      organizationName: organizationName,
      profilePicture: profilePicture,
      bio: bio,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      location: location,
      organizationType: organizationType,
      eventTypes: eventTypes,
      verificationDocuments: verificationDocuments,
      website: website,
      photos: photos,
      videos: videos,
      isVerified: isVerified,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory OrganizerApiModel.fromEntity(OrganizerEntity entity) {
    return OrganizerApiModel(
      id: entity.id,
      userId: entity.userId,
      organizationName: entity.organizationName,
      profilePicture: entity.profilePicture,
      bio: entity.bio,
      contactPerson: entity.contactPerson,
      phone: entity.phone,
      email: entity.email,
      location: Map<String, dynamic>.from(entity.location),
      organizationType: entity.organizationType,
      eventTypes: entity.eventTypes,
      verificationDocuments: entity.verificationDocuments,
      website: entity.website,
      photos: entity.photos,
      videos: entity.videos,
      isVerified: entity.isVerified,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
