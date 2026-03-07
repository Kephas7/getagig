import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/services/connectivity/network_info.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:getagig/features/organizer/data/datasources/local/organizer_local_datasource.dart';
import 'package:getagig/features/organizer/data/datasources/organizer_datasource.dart';
import 'package:getagig/features/organizer/data/datasources/remote/organizer_remote_datasource.dart';
import 'package:getagig/features/organizer/data/models/organizer_hive_model.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';

final organizerRepositoryProvider = Provider<IOrganizerRepository>((ref) {
  final remoteDatasource = ref.read(organizerRemoteDataSourceProvider);
  final localDatasource = ref.read(organizerLocalDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return OrganizerRepository(
    remoteDataSource: remoteDatasource,
    localDataSource: localDatasource,
    networkInfo: networkInfo,
    userSessionService: userSessionService,
  );
});

class OrganizerRepository implements IOrganizerRepository {
  final IOrganizerRemoteDataSource remoteDataSource;
  final IOrganizerLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final UserSessionService userSessionService;

  OrganizerRepository({
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

  Future<void> _cacheProfile(OrganizerEntity profile) async {
    try {
      await localDataSource.cacheProfile(
        OrganizerHiveModel.fromEntity(profile),
      );
    } catch (_) {
      // Cache failures should not block successful API flows.
    }
  }

  Future<OrganizerEntity?> _readCachedProfile({
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
  Future<Either<Failure, OrganizerEntity>> createProfile(
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
  Future<Either<Failure, OrganizerEntity>> getProfile() async {
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
        LocalDatabaseFailure(message: 'No cached organizer profile available'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> getProfileById(String id) async {
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
        LocalDatabaseFailure(message: 'No cached organizer profile available'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> updateProfile(
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
  Future<Either<Failure, OrganizerEntity>> uploadProfilePicture(
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
  Future<Either<Failure, OrganizerEntity>> addPhotos(List<File> files) async {
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
  Future<Either<Failure, OrganizerEntity>> removePhoto(String photoUrl) async {
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
  Future<Either<Failure, OrganizerEntity>> addVideos(List<File> files) async {
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
  Future<Either<Failure, OrganizerEntity>> removeVideo(String videoUrl) async {
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
  Future<Either<Failure, OrganizerEntity>> addVerificationDocuments(
    List<File> files,
  ) async {
    try {
      final model = await remoteDataSource.addVerificationDocuments(files);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to add documents'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> removeVerificationDocument(
    String documentUrl,
  ) async {
    try {
      final model = await remoteDataSource.removeVerificationDocument(
        documentUrl,
      );
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to remove document'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> updateActiveStatus(
    bool isActive,
  ) async {
    try {
      final model = await remoteDataSource.updateActiveStatus(isActive);
      final entity = model.toEntity();
      await _cacheProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to update status'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> requestVerification() async {
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
