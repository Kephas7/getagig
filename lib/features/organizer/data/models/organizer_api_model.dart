import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/organizer_entity.dart';

part 'organizer_api_model.g.dart';

@JsonSerializable()
class OrganizerApiModel {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String organizationName;
  final String? profilePicture;
  final String? bio;
  @JsonKey(defaultValue: '')
  final String contactPerson;
  @JsonKey(defaultValue: '')
  final String phone;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: '')
  final String location;
  @JsonKey(defaultValue: '')
  final String organizationType;
  @JsonKey(defaultValue: [])
  final List<String> eventTypes;
  @JsonKey(defaultValue: [])
  final List<String> verificationDocuments;
  final String? website;
  @JsonKey(defaultValue: [])
  final List<String> photos;
  @JsonKey(defaultValue: [])
  final List<String> videos;
  @JsonKey(defaultValue: false)
  final bool isVerified;
  @JsonKey(defaultValue: false)
  final bool verificationRequested;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
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
    required this.verificationRequested,
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
      verificationRequested: verificationRequested,
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
      location: entity.location,
      organizationType: entity.organizationType,
      eventTypes: entity.eventTypes,
      verificationDocuments: entity.verificationDocuments,
      website: entity.website,
      photos: entity.photos,
      videos: entity.videos,
      isVerified: entity.isVerified,
      verificationRequested: entity.verificationRequested,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
