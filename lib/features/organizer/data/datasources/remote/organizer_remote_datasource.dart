import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/organizer/data/datasources/organizer_datasource.dart';
import 'package:getagig/features/organizer/data/models/organizer_api_model.dart';

final organizerRemoteDataSourceProvider = Provider<IOrganizerRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return OrganizerRemoteDataSource(apiClient: apiClient);
});

class OrganizerRemoteDataSource implements IOrganizerRemoteDataSource {
  final ApiClient apiClient;

  OrganizerRemoteDataSource({required this.apiClient});

  @override
  Future<OrganizerApiModel> createProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.organizerProfile,
        data: data,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to create profile');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> getProfile() async {
    try {
      final response = await apiClient.get(ApiEndpoints.organizerProfile);

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to get profile');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> getProfileById(String id) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.organizerProfileById(id),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to get profile');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.organizerProfile,
        data: data,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to update profile');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      final response = await apiClient.delete(ApiEndpoints.organizerProfile);

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete profile');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> uploadProfilePicture(File file) async {
    try {
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await apiClient.post(
        ApiEndpoints.organizerProfilePicture,
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Failed to upload profile picture',
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> addPhotos(List<File> files) async {
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
        ApiEndpoints.organizerPhotos,
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to add photos');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> removePhoto(String photoUrl) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.organizerPhotos,
        data: {'photoUrl': photoUrl},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to remove photo');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> addVideos(List<File> files) async {
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
        ApiEndpoints.organizerVideos,
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to add videos');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> removeVideo(String videoUrl) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.organizerVideos,
        data: {'videoUrl': videoUrl},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to remove video');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> addVerificationDocuments(List<File> files) async {
    try {
      final formData = FormData.fromMap({
        'verificationDocuments': await Future.wait(
          files.map(
            (file) => MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        ),
      });

      final response = await apiClient.post(
        ApiEndpoints.organizerDocuments,
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Failed to add verification documents',
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> removeVerificationDocument(
    String documentUrl,
  ) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.organizerDocuments,
        data: {'documentUrl': documentUrl},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Failed to remove verification document',
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<OrganizerApiModel> updateActiveStatus(bool isActive) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.organizerActiveStatus,
        data: {'isActive': isActive},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return OrganizerApiModel.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Failed to update active status',
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

