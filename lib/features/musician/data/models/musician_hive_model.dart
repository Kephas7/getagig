import 'package:getagig/core/constants/hive_table_constant.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:hive/hive.dart';

part 'musician_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.musicianProfileTypeId)
class MusicianHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String stageName;

  @HiveField(3)
  final String? profilePicture;

  @HiveField(4)
  final String? bio;

  @HiveField(5)
  final String phone;

  @HiveField(6)
  final String location;

  @HiveField(7)
  final List<String> genres;

  @HiveField(8)
  final List<String> instruments;

  @HiveField(9)
  final int experienceYears;

  @HiveField(10)
  final double? hourlyRate;

  @HiveField(11)
  final List<String> photos;

  @HiveField(12)
  final List<String> videos;

  @HiveField(13)
  final List<String> audioSamples;

  @HiveField(14)
  final bool isVerified;

  @HiveField(15)
  final bool verificationRequested;

  @HiveField(16)
  final bool isAvailable;

  @HiveField(17)
  final String createdAt;

  @HiveField(18)
  final String updatedAt;

  MusicianHiveModel({
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

  factory MusicianHiveModel.fromEntity(MusicianEntity entity) {
    return MusicianHiveModel(
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
}
