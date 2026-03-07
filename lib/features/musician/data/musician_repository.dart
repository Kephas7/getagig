import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/services/connectivity/network_info.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:getagig/features/musician/data/datasources/local/musician_local_datasource.dart';
import 'package:getagig/features/musician/data/datasources/musician_datasource.dart';
import 'package:getagig/features/musician/data/datasources/remote/musician_remote_datasource.dart';
import 'package:getagig/features/musician/data/models/musician_hive_model.dart';
import 'package:getagig/features/musician/domain/entities/musician_entity.dart';
import 'package:getagig/features/musician/domain/repositories/musician_repository.dart';

final musicianRepositoryProvider = Provider<IMusicianRepository>((ref) {
  final remoteDatasource = ref.read(musicianRemoteDataSourceProvider);
  final localDatasource = ref.read(musicianLocalDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return MusicianRepository(
    remoteDataSource: remoteDatasource,
    localDataSource: localDatasource,
    networkInfo: networkInfo,
    userSessionService: userSessionService,
  );
});

class MusicianRepository implements IMusicianRepository {
  final IMusicianRemoteDataSource remoteDataSource;
  final IMusicianLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final UserSessionService userSessionService;

  MusicianRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.userSessionService,
  });

  bool _isConnectivityIssue(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    return error.type == DioExceptionType.unknown &&
        error.error is SocketException;
  }

  String? _currentUserId() {
    final userId = userSessionService.getCurrentUserId()?.trim();
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  Future<void> _cacheProfile(MusicianEntity profile) async {
    try {
      await localDataSource.cacheProfile(MusicianHiveModel.fromEntity(profile));
    } catch (_) {
      // Cache failures should not block successful API flows.
    }
  }

  Future<MusicianEntity?> _readCachedProfile({
    String? profileId,
    String? userId,
  }) async {
    final trimmedProfileId = profileId?.trim();
    if (trimmedProfileId != null && trimmedProfileId.isNotEmpty) {
      final cached = await localDataSource.getCachedProfileById(
        trimmedProfileId,
      );
      if (cached != null) {
        return cached.toEntity();
      }
    }

    final trimmedUserId = userId?.trim();
    if (trimmedUserId != null && trimmedUserId.isNotEmpty) {
      final cached = await localDataSource.getCachedProfileByUserId(
        trimmedUserId,
      );
      if (cached != null) {
        return cached.toEntity();
      }
    }

    return null;
  }

  @override
  Future<Either<Failure, MusicianEntity>> createProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.createProfile(data);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to create profile'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getProfile();
        final entity = model.toEntity();
        await _cacheProfile(entity);
        return Right(entity);
      } on DioException catch (e) {
        if (!_isConnectivityIssue(e)) {
          return Left(
            ApiFailure.fromDioException(e, fallback: 'Failed to fetch profile'),
          );
        }
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      final cached = await _readCachedProfile(userId: _currentUserId());
      if (cached != null) {
        return Right(cached);
      }
      return const Left(
        LocalDatabaseFailure(message: 'No cached musician profile available'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> getProfileById(String id) async {
    final profileId = id.trim();

    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getProfileById(profileId);
        final entity = model.toEntity();
        await _cacheProfile(entity);
        return Right(entity);
      } on DioException catch (e) {
        if (!_isConnectivityIssue(e)) {
          return Left(
            ApiFailure.fromDioException(e, fallback: 'Failed to fetch profile'),
          );
        }
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      final cached = await _readCachedProfile(
        profileId: profileId,
        userId: profileId,
      );
      if (cached != null) {
        return Right(cached);
      }
      return const Left(
        LocalDatabaseFailure(message: 'No cached musician profile available'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.updateProfile(data);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to update profile'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile() async {
    try {
      await remoteDataSource.deleteProfile();

      final userId = _currentUserId();
      if (userId != null) {
        await localDataSource.deleteCachedProfileByUserId(userId);
      }

      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to delete profile'),
      );
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
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to upload profile picture',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> addPhotos(List<File> files) async {
    try {
      final model = await remoteDataSource.addPhotos(files);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to add photos'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> removePhoto(String photoUrl) async {
    try {
      final model = await remoteDataSource.removePhoto(photoUrl);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to remove photo'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> addVideos(List<File> files) async {
    try {
      final model = await remoteDataSource.addVideos(files);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to add videos'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> removeVideo(String videoUrl) async {
    try {
      final model = await remoteDataSource.removeVideo(videoUrl);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to remove video'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> addAudio(List<File> files) async {
    try {
      final model = await remoteDataSource.addAudio(files);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to add audio'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> removeAudio(String audioUrl) async {
    try {
      final model = await remoteDataSource.removeAudio(audioUrl);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to remove audio'),
      );
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
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to update availability',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MusicianEntity>> requestVerification() async {
    try {
      final model = await remoteDataSource.requestVerification();
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to request verification',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
