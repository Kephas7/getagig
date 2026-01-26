import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';

part 'musician_api_model.g.dart';
@JsonSerializable()
class MusicianApiModel {
final String id;
  final String userId;
  final String stageName;
  final String? profilePicture;
  final String? bio;
  final String phone;
  final Map<String, String> location;
  final List<String> genres;
  final List<String> instruments;
  final int experienceYears;
  final double? hourlyRate;
  final List<String> photos;
  final List<String> videos;
  final List<String> audioSamples;
  final bool isAvailable;
  
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
  });

  factory MusicianApiModel.fromJson(Map<String, dynamic> json) => _$MusicianApiModelFromJson(json);
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
    );
  }
  factory MusicianApiModel.fromEntity(MusicianEntity entity) {
    return MusicianApiModel(
      id: entity.id,
      userId: entity.userId,
      stageName: entity.stageName,
      profilePicture: entity.profilePicture,
      bio:  entity.bio,
      phone: entity.phone,
      location: entity.location,
      genres: entity.genres,
      instruments: entity.instruments,
      experienceYears: entity.experienceYears,
      hourlyRate: entity.hourlyRate,
      photos: entity.photos,
      videos: entity.videos,
      audioSamples: entity.audioSamples,
      isAvailable: entity.isAvailable,
    );
  }



  static List<MusicianEntity> toEntityList(List<MusicianApiModel> models) {
    return models.map((model)=>model.toEntity())
        .toList();
  }
}