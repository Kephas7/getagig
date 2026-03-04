import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/musician_entity.dart';

part 'musician_api_model.g.dart';

@JsonSerializable()
class MusicianApiModel {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String stageName;
  final String? profilePicture;
  final String? bio;
  @JsonKey(defaultValue: '')
  final String phone;
  @JsonKey(defaultValue: '')
  final String location;
  @JsonKey(defaultValue: [])
  final List<String> genres;
  @JsonKey(defaultValue: [])
  final List<String> instruments;
  @JsonKey(defaultValue: 0)
  final int experienceYears;
  final double? hourlyRate;
  @JsonKey(defaultValue: [])
  final List<String> photos;
  @JsonKey(defaultValue: [])
  final List<String> videos;
  @JsonKey(defaultValue: [])
  final List<String> audioSamples;
  @JsonKey(defaultValue: false)
  final bool isVerified;
  @JsonKey(defaultValue: false)
  final bool verificationRequested;
  @JsonKey(defaultValue: true)
  final bool isAvailable;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
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
    required this.isVerified,
    required this.verificationRequested,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MusicianApiModel.fromJson(Map<String, dynamic> json) =>
      _$MusicianApiModelFromJson(json);

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
      isVerified: isVerified,
      verificationRequested: verificationRequested,
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
      location: entity.location,
      genres: entity.genres,
      instruments: entity.instruments,
      experienceYears: entity.experienceYears,
      hourlyRate: entity.hourlyRate,
      photos: entity.photos,
      videos: entity.videos,
      audioSamples: entity.audioSamples,
      isVerified: entity.isVerified,
      verificationRequested: entity.verificationRequested,
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
