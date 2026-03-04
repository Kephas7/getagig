// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizerApiModel _$OrganizerApiModelFromJson(Map<String, dynamic> json) =>
    OrganizerApiModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      organizationName: json['organizationName'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      contactPerson: json['contactPerson'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      location: json['location'] as String? ?? '',
      organizationType: json['organizationType'] as String? ?? '',
      eventTypes: (json['eventTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      verificationDocuments: (json['verificationDocuments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      website: json['website'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isVerified: json['isVerified'] as bool? ?? false,
      verificationRequested: json['verificationRequested'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$OrganizerApiModelToJson(OrganizerApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'organizationName': instance.organizationName,
      'profilePicture': instance.profilePicture,
      'bio': instance.bio,
      'contactPerson': instance.contactPerson,
      'phone': instance.phone,
      'email': instance.email,
      'location': instance.location,
      'organizationType': instance.organizationType,
      'eventTypes': instance.eventTypes,
      'verificationDocuments': instance.verificationDocuments,
      'website': instance.website,
      'photos': instance.photos,
      'videos': instance.videos,
      'isVerified': instance.isVerified,
      'verificationRequested': instance.verificationRequested,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
