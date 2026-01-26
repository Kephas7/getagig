import 'package:equatable/equatable.dart';

class MusicianEntity extends Equatable {
  final String id;
  final String userId;
  final String stageName;
  final String? profilePicture;
  final String? bio;
  final String phone;
  final LocationEntity location;
  final List<String> genres;
  final List<String> instruments;
  final int experienceYears;
  final double? hourlyRate;
  final List<String> photos;
  final List<String> videos;
  final List<String> audioSamples;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    isAvailable,
    createdAt,
    updatedAt,
  ];
}

class LocationEntity extends Equatable {
  final String city;
  final String state;
  final String country;

  const LocationEntity({
    required this.city,
    required this.state,
    required this.country,
  });

  @override
  List<Object?> get props => [city, state, country];
}
