// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationModel _$ApplicationModelFromJson(Map<String, dynamic> json) =>
    ApplicationModel(
      id: _readId(json, '_id') as String?,
      gigId: json['gigId'] as String?,
      musicianId: json['musicianId'] as String?,
      gig: json['gig'] == null
          ? null
          : GigModel.fromJson(json['gig'] as Map<String, dynamic>),
      musician: json['musician'] == null
          ? null
          : AuthApiModel.fromJson(json['musician'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'pending',
      coverLetter: json['coverLetter'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ApplicationModelToJson(ApplicationModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'gigId': instance.gigId,
      'musicianId': instance.musicianId,
      'gig': instance.gig,
      'musician': instance.musician,
      'status': instance.status,
      'coverLetter': instance.coverLetter,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
