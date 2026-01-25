class MusicianEntity {
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

  MusicianEntity({
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
}
