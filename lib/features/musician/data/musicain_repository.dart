import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/musician/data/datasources/musician_datasource.dart';
import 'package:getagig/features/musician/data/datasources/remote/musicain_remote_datasource.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import '../../../../core/error/failures.dart';

final musicianRepositoryProvider = Provider<IMusicianRepository>((ref) {
  final remoteDatasource = ref.read(musicianRemoteDataSourceProvider);
  return MusicianRepository(remoteDataSource: remoteDatasource);
});

class MusicianRepository implements IMusicianRepository {
  final IMusicianRemoteDataSource remoteDataSource;

  MusicianRepository({required this.remoteDataSource});

  @override
  Future<Either<Failures, MusicianEntity>> createProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.createProfile(data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> getProfile() async {
    try {
      final model = await remoteDataSource.getProfile();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> getProfileById(String id) async {
    try {
      final model = await remoteDataSource.getProfileById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.updateProfile(data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, void>> deleteProfile() async {
    try {
      await remoteDataSource.deleteProfile();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> uploadProfilePicture(
    File file,
  ) async {
    try {
      final model = await remoteDataSource.uploadProfilePicture(file);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> addPhotos(List<File> files) async {
    try {
      final model = await remoteDataSource.addPhotos(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> removePhoto(String photoUrl) async {
    try {
      final model = await remoteDataSource.removePhoto(photoUrl);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> addVideos(List<File> files) async {
    try {
      final model = await remoteDataSource.addVideos(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> removeVideo(String videoUrl) async {
    try {
      final model = await remoteDataSource.removeVideo(videoUrl);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> addAudio(List<File> files) async {
    try {
      final model = await remoteDataSource.addAudio(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> removeAudio(String audioUrl) async {
    try {
      final model = await remoteDataSource.removeAudio(audioUrl);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, MusicianEntity>> updateAvailability(
    bool isAvailable,
  ) async {
    try {
      final model = await remoteDataSource.updateAvailability(isAvailable);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Failures _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        String? message;
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String?;
        }

        return ApiFailure(
          message: message ?? _getDefaultMessageForStatusCode(statusCode),
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const ApiFailure(message: 'Request was cancelled.');

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'No internet connection. Please check your network.',
        );

      default:
        return const ApiFailure(
          message: 'An unexpected error occurred. Please try again.',
        );
    }
  }

  String _getDefaultMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 404:
        return 'Profile not found.';
      case 409:
        return 'Profile already exists.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
