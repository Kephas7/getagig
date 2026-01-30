import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/musician_entity.dart';

part 'musician_api_model.g.dart';

@JsonSerializable(createToJson: true, createFactory: false)
class MusicianApiModel {
  final String id;
  final String userId;
  final String stageName;
  final String? profilePicture;
  final String? bio;
  final String phone;
  final Map<String, dynamic> location; 
  final List<String> genres;
  final List<String> instruments;
  final int experienceYears;
  final double? hourlyRate;
  final List<String> photos;
  final List<String> videos;
  final List<String> audioSamples;
  final bool isAvailable;
  final String createdAt;
  final String updatedAt;

  MusicianApiModel({
    required this.id,
    required this.userId,
    required this.stageName,
    this.profilePicture,
    this.bio,
    required this.phone,
    required this.location,
    required this.genres,
    required this.instruments,
    required this.experienceYears,
    this.hourlyRate,
    required this.photos,
    required this.videos,
    required this.audioSamples,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MusicianApiModel.fromJson(Map<String, dynamic> json) {
    try {
      
      return MusicianApiModel(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        stageName: json['stageName'] as String? ?? '',
        profilePicture: json['profilePicture'] as String?,
        bio: json['bio'] as String?,
        phone: json['phone'] as String? ?? '',
        location: _parseLocation(json['location']),
        genres: _parseStringList(json['genres']),
        instruments: _parseStringList(json['instruments']),
        experienceYears: json['experienceYears'] != null
            ? (json['experienceYears'] as num).toInt()
            : 0,
        hourlyRate: json['hourlyRate'] != null
            ? (json['hourlyRate'] as num).toDouble()
            : null,
        photos: _parseStringList(json['photos']),
        videos: _parseStringList(json['videos']),
        audioSamples: _parseStringList(json['audioSamples']),
        isAvailable: json['isAvailable'] as bool? ?? true,
        createdAt: json['createdAt'] as String? ?? '',
        updatedAt: json['updatedAt'] as String? ?? '',
      );
    } catch (e) {
      throw FormatException('Failed to parse MusicianApiModel: $e');
    }
  }

  
  static Map<String, dynamic> _parseLocation(dynamic location) {
    try {
      if (location == null) {
        return {'city': '', 'state': '', 'country': ''};
      }
      if (location is Map) {
        final map = Map<String, dynamic>.from(location);
        
        map.putIfAbsent('city', () => '');
        map.putIfAbsent('state', () => '');
        map.putIfAbsent('country', () => '');
        return map;
      }
      
      return {'city': '', 'state': '', 'country': ''};
    } catch (e) {
      return {'city': '', 'state': '', 'country': ''};
    }
  }

  
  static List<String> _parseStringList(dynamic list) {
    try {
      if (list == null) return [];
      if (list is List) {
        return list.map((e) {
          if (e == null) return '';
          return e.toString();
        }).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() => _$MusicianApiModelToJson(this);

  MusicianEntity toEntity() {
    return MusicianEntity(
      id: id,
      userId: userId,
      stageName: stageName,
      profilePicture: profilePicture,
      bio: bio,
      phone: phone,
      location: location,
      genres: genres,
      instruments: instruments,
      experienceYears: experienceYears,
      hourlyRate: hourlyRate,
      photos: photos,
      videos: videos,
      audioSamples: audioSamples,
      isAvailable: isAvailable,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory MusicianApiModel.fromEntity(MusicianEntity entity) {
    return MusicianApiModel(
      id: entity.id,
      userId: entity.userId,
      stageName: entity.stageName,
      profilePicture: entity.profilePicture,
      bio: entity.bio,
      phone: entity.phone,
      location: Map<String, dynamic>.from(entity.location),
      genres: entity.genres,
      instruments: entity.instruments,
      experienceYears: entity.experienceYears,
      hourlyRate: entity.hourlyRate,
      photos: entity.photos,
      videos: entity.videos,
      audioSamples: entity.audioSamples,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<MusicianEntity> toEntityList(List<MusicianApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  static List<MusicianApiModel> fromEntityList(List<MusicianEntity> entities) {
    return entities
        .map((entity) => MusicianApiModel.fromEntity(entity))
        .toList();
  }
}
