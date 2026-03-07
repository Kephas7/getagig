import 'dart:io';

import 'package:getagig/features/musician/data/models/musician_hive_model.dart';
import 'package:getagig/features/musician/data/models/musician_api_model.dart';

abstract interface class IMusicianRemoteDataSource {
  Future<MusicianApiModel> createProfile(Map<String, dynamic> data);
  Future<MusicianApiModel> getProfile();
  Future<MusicianApiModel> getProfileById(String id);
  Future<MusicianApiModel> updateProfile(Map<String, dynamic> data);
  Future<void> deleteProfile();
  Future<MusicianApiModel> uploadProfilePicture(File file);
  Future<MusicianApiModel> addPhotos(List<File> files);
  Future<MusicianApiModel> removePhoto(String photoUrl);
  Future<MusicianApiModel> addVideos(List<File> files);
  Future<MusicianApiModel> removeVideo(String videoUrl);
  Future<MusicianApiModel> addAudio(List<File> files);
  Future<MusicianApiModel> removeAudio(String audioUrl);
  Future<MusicianApiModel> updateAvailability(bool isAvailable);
  Future<MusicianApiModel> requestVerification();
}

abstract interface class IMusicianLocalDataSource {
  Future<void> cacheProfile(MusicianHiveModel profile);
  Future<MusicianHiveModel?> getCachedProfileById(String id);
  Future<MusicianHiveModel?> getCachedProfileByUserId(String userId);
  Future<void> deleteCachedProfileById(String id);
  Future<void> deleteCachedProfileByUserId(String userId);
}
