import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/musician/data/datasources/musician_datasource.dart';
import 'package:getagig/features/musician/data/models/musician_api_model.dart';

final musicianRemoteDataSourceProvider = Provider<IMusicianRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return MusicianRemoteDataSource(apiClient: apiClient);
});

class MusicianRemoteDataSource implements IMusicianRemoteDataSource {
  final ApiClient apiClient;

  MusicianRemoteDataSource({required this.apiClient});

  @override
  Future<MusicianApiModel> createProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.musicianProfile,
        data: data,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to create profile');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> getProfile() async {
    try {
      final response = await apiClient.get(ApiEndpoints.musicianProfile);

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to get profile');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> getProfileById(String id) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.musicianProfileById(id),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to get profile');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.musicianProfile,
        data: data,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to update profile');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      final response = await apiClient.delete(ApiEndpoints.musicianProfile);

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete profile');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> uploadProfilePicture(File file) async {
    try {
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await apiClient.post(
        ApiEndpoints.musicianProfilePicture,
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Failed to upload profile picture',
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> addPhotos(List<File> files) async {
    try {
      final formData = FormData.fromMap({
        'photos': await Future.wait(
          files.map(
            (file) => MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        ),
      });

      final response = await apiClient.post(
        ApiEndpoints.musicianPhotos,
        data: formData,
      );

      print('Add Photos Response: ${response.data}');

      if (response.data['success'] == true && response.data['data'] != null) {
        final model = MusicianApiModel.fromJson(response.data['data']);
        print('Parsed Photos: ${model.photos}');
        return model;
      }

      throw Exception(response.data['message'] ?? 'Failed to add photos');
    } on DioException catch (e) {
      print('DioException in addPhotos: ${e.message}');
      throw Exception(_handleError(e));
    } catch (e) {
      print('Exception in addPhotos: $e');
      rethrow;
    }
  }

  @override
  Future<MusicianApiModel> removePhoto(String photoUrl) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.musicianPhotos,
        data: {'photoUrl': photoUrl},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to remove photo');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> addVideos(List<File> files) async {
    try {
      final formData = FormData.fromMap({
        'videos': await Future.wait(
          files.map(
            (file) => MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        ),
      });

      final response = await apiClient.post(
        ApiEndpoints.musicianVideos,
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to add videos');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> removeVideo(String videoUrl) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.musicianVideos,
        data: {'videoUrl': videoUrl},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to remove video');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> addAudio(List<File> files) async {
    try {
      final formData = FormData.fromMap({
        'audioSamples': await Future.wait(
          files.map(
            (file) => MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        ),
      });

      final response = await apiClient.post(
        ApiEndpoints.musicianAudio,
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to add audio');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> removeAudio(String audioUrl) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.musicianAudio,
        data: {'audioUrl': audioUrl},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to remove audio');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<MusicianApiModel> updateAvailability(bool isAvailable) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.musicianAvailability,
        data: {'isAvailable': isAvailable},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MusicianApiModel.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Failed to update availability',
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        String? message;
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String?;
        }

        if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          return 'Profile not found.';
        } else if (statusCode == 409) {
          return message ?? 'Profile already exists.';
        } else if (statusCode == 400) {
          return message ?? 'Invalid request. Please check your input.';
        }
        return message ?? 'Something went wrong. Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
