// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'musician_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicianApiModel _$MusicianApiModelFromJson(Map<String, dynamic> json) =>
    MusicianApiModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stageName: json['stageName'] as String,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String,
      location: Map<String, String>.from(json['location'] as Map),
      genres:
          (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
      instruments: (json['instruments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      experienceYears: (json['experienceYears'] as num).toInt(),
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      photos:
          (json['photos'] as List<dynamic>).map((e) => e as String).toList(),
      videos:
          (json['videos'] as List<dynamic>).map((e) => e as String).toList(),
      audioSamples: (json['audioSamples'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isAvailable: json['isAvailable'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$MusicianApiModelToJson(MusicianApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'stageName': instance.stageName,
      'profilePicture': instance.profilePicture,
      'bio': instance.bio,
      'phone': instance.phone,
      'location': instance.location,
      'genres': instance.genres,
      'instruments': instance.instruments,
      'experienceYears': instance.experienceYears,
      'hourlyRate': instance.hourlyRate,
      'photos': instance.photos,
      'videos': instance.videos,
      'audioSamples': instance.audioSamples,
      'isAvailable': instance.isAvailable,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
