import 'package:equatable/equatable.dart';

class MusicianEntity extends Equatable {
  final String id;
  final String userId;
  final String stageName;
  final String? profilePicture;
  final String? bio;
  final String phone;
  final String location;
  final List<String> genres;
  final List<String> instruments;
  final int experienceYears;
  final double? hourlyRate;
  final List<String> photos;
  final List<String> videos;
  final List<String> audioSamples;
  final bool isVerified;
  final bool verificationRequested;
  final bool isAvailable;
  final String createdAt;
  final String updatedAt;

  const MusicianEntity({
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

  @override
  List<Object?> get props => [
    id,
    userId,
    stageName,
    profilePicture,
    bio,
    phone,
    location,
    genres,
    instruments,
    experienceYears,
    hourlyRate,
    photos,
    videos,
    audioSamples,
    isVerified,
    verificationRequested,
    isAvailable,
    createdAt,
    updatedAt,
  ];
}
