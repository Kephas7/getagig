import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:hive/hive.dart';

part 'organizer_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.organizerProfileTypeId)
class OrganizerHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String organizationName;

  @HiveField(3)
  final String? profilePicture;

  @HiveField(4)
  final String? bio;

  @HiveField(5)
  final String contactPerson;

  @HiveField(6)
  final String phone;

  @HiveField(7)
  final String email;

  @HiveField(8)
  final String location;

  @HiveField(9)
  final String organizationType;

  @HiveField(10)
  final List<String> eventTypes;

  @HiveField(11)
  final List<String> verificationDocuments;

  @HiveField(12)
  final String? website;

  @HiveField(13)
  final List<String> photos;

  @HiveField(14)
  final List<String> videos;

  @HiveField(15)
  final bool isVerified;

  @HiveField(16)
  final bool verificationRequested;

  @HiveField(17)
  final bool isActive;

  @HiveField(18)
  final String createdAt;

  @HiveField(19)
  final String updatedAt;

  OrganizerHiveModel({
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

  factory OrganizerHiveModel.fromEntity(OrganizerEntity entity) {
    return OrganizerHiveModel(
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
}
