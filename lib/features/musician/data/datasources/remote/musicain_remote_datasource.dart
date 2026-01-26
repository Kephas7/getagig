import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/musician/data/datasources/musician_datasource.dart';
import 'package:getagig/features/musician/data/models/musician_api_model.dart';

class MusicainRemoteDatasource implements IMusicianRemoteDataSource {
  final ApiClient _apiClient;
  final _secureStorage = const FlutterSecureStorage();

  MusicainRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<bool> createMusicianProfile(MusicianApiModel musician) async {
    final token = await _secureStorage.read(key: 'auth_token');
    final response = await _apiClient.post(ApiEndpoints.MusicianProfile,data: musician.toJson(),options:Options(
      headers: {
        'Authorization': 'Bearer $token',
      },));
  
  }

  @override
  Future<Map<String, dynamic>?> updateMusicianProfile(MusicianApiModel musician) {
    // TODO: implement updateMusicianProfile
    throw UnimplementedError();
  }

  @override
  Future<bool> uploadAudios(List<File> audios) {
    // TODO: implement uploadAudios
    throw UnimplementedError();
  }

  @override
  Future<bool> uploadPhotos(List<File> photos) {
    // TODO: implement uploadPhotos
    throw UnimplementedError();
  }

  @override
  Future<bool> uploadProfilePicture(File photo) {
    // TODO: implement uploadProfilePicture
    throw UnimplementedError();
  }

  @override
  Future<bool> uploadVideos(List<File> videos) {
    // TODO: implement uploadVideos
    throw UnimplementedError();
  }

  

}