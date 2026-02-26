// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GigModelImpl _$$GigModelImplFromJson(Map<String, dynamic> json) =>
    _$GigModelImpl(
      id: _readId(json, '_id') as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] == null
          ? const LocationModel()
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      instruments: (json['instruments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      payRate: (json['payRate'] as num?)?.toDouble() ?? 0.0,
      eventType: json['eventType'] as String? ?? '',
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      status: json['status'] as String? ?? 'open',
      organizer: json['organizer'] == null
          ? null
          : AuthApiModel.fromJson(json['organizer'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$GigModelImplToJson(_$GigModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'genres': instance.genres,
      'instruments': instance.instruments,
      'payRate': instance.payRate,
      'eventType': instance.eventType,
      'deadline': instance.deadline?.toIso8601String(),
      'status': instance.status,
      'organizer': instance.organizer,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
