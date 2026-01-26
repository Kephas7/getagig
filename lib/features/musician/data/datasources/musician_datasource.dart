import 'dart:io';

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
}