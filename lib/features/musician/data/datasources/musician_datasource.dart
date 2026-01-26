import 'dart:io';

import 'package:getagig/features/musician/data/models/musician_api_model.dart';

abstract interface class IMusicianRemoteDataSource {
  Future<bool> createMusicianProfile(MusicianApiModel musician);
  Future<Map<String, dynamic>?> updateMusicianProfile(MusicianApiModel musician);
  Future<bool> uploadProfilePicture(File photo);
  Future<bool> uploadPhotos(List<File> photos);
  Future<bool> uploadVideos(List<File> videos);
  Future<bool> uploadAudios(List<File> audios);
}