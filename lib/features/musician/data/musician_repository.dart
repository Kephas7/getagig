import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/musician/data/datasources/musician_datasource.dart';
import 'package:getagig/features/musician/data/datasources/remote/musician_remote_datasource.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';
import 'package:getagig/core/error/failures.dart';

final musicianRepositoryProvider = Provider<IMusicianRepository>((ref) {
  final remoteDatasource = ref.read(musicianRemoteDataSourceProvider);
  return MusicianRepository(remoteDataSource: remoteDatasource);
});

class MusicianRepository implements IMusicianRepository {
  final IMusicianRemoteDataSource remoteDataSource;

  MusicianRepository({required this.remoteDataSource});

  @override
  Future<Either<Failure, MusicianEntity>> createProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.createProfile(data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to create profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> getProfile() async {
    try {
      final model = await remoteDataSource.getProfile();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to fetch profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> getProfileById(String id) async {
    try {
      final model = await remoteDataSource.getProfileById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to fetch profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.updateProfile(data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to update profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile() async {
    try {
      await remoteDataSource.deleteProfile();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to delete profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> uploadProfilePicture(
    File file,
  ) async {
    try {
      final model = await remoteDataSource.uploadProfilePicture(file);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to upload profile picture'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> addPhotos(List<File> files) async {
    try {
      final model = await remoteDataSource.addPhotos(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to add photos'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> removePhoto(String photoUrl) async {
    try {
      final model = await remoteDataSource.removePhoto(photoUrl);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to remove photo'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> addVideos(List<File> files) async {
    try {
      final model = await remoteDataSource.addVideos(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to add videos'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> removeVideo(String videoUrl) async {
    try {
      final model = await remoteDataSource.removeVideo(videoUrl);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to remove video'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> addAudio(List<File> files) async {
    try {
      final model = await remoteDataSource.addAudio(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to add audio'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> removeAudio(String audioUrl) async {
    try {
      final model = await remoteDataSource.removeAudio(audioUrl);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to remove audio'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> updateAvailability(
    bool isAvailable,
  ) async {
    try {
      final model = await remoteDataSource.updateAvailability(isAvailable);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to update availability'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

