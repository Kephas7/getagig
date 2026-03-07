import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/services/connectivity/network_info.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:getagig/features/applications/data/datasources/applications_datasource.dart';
import 'package:getagig/features/applications/data/datasources/local/applications_local_datasource.dart';
import 'package:getagig/features/applications/data/datasources/remote/applications_remote_datasource.dart';
import 'package:getagig/features/applications/data/models/application_hive_model.dart';
import 'package:getagig/features/applications/data/models/application_model.dart';
import 'package:getagig/features/applications/domain/entities/application_entity.dart';
import 'package:getagig/features/applications/domain/repositories/application_repository.dart';

final applicationRepositoryProvider = Provider<IApplicationRepository>((ref) {
  return ApplicationRepository(
    remoteDataSource: ref.read(applicationsRemoteDataSourceProvider),
    localDataSource: ref.read(applicationsLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class ApplicationRepository implements IApplicationRepository {
  final IApplicationsRemoteDataSource remoteDataSource;
  final IApplicationsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final UserSessionService userSessionService;

  ApplicationRepository({
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

  Future<void> _cacheMyApplications(
    String userId,
    List<ApplicationModel> applications,
  ) async {
    try {
      final mapped = applications
          .map(ApplicationHiveModel.fromModel)
          .toList(growable: false);
      await localDataSource.cacheMyApplications(userId, mapped);
    } catch (_) {
      // Cache failures should not block successful API flows.
    }
  }

  Future<void> _cacheGigApplications(
    String gigId,
    List<ApplicationModel> applications,
  ) async {
    try {
      final mapped = applications
          .map(ApplicationHiveModel.fromModel)
          .toList(growable: false);
      await localDataSource.cacheGigApplications(gigId, mapped);
    } catch (_) {
      // Cache failures should not block successful API flows.
    }
  }

  Future<void> _upsertApplication(ApplicationModel application) async {
    try {
      await localDataSource.upsertApplication(
        ApplicationHiveModel.fromModel(application),
      );
    } catch (_) {
      // Cache failures should not block successful API flows.
    }
  }

  @override
  Future<Either<Failure, List<ApplicationEntity>>> getMyApplications() async {
    final userId = _currentUserId();

    if (await networkInfo.isConnected) {
      try {
        final applications = await remoteDataSource.getMyApplications();
        if (userId != null) {
          await _cacheMyApplications(userId, applications);
        }
        return Right(applications.map((item) => item.toEntity()).toList());
      } on DioException catch (e) {
        if (!_isConnectivityIssue(e)) {
          return Left(
            ApiFailure.fromDioException(
              e,
              fallback: 'Failed to fetch applications',
            ),
          );
        }
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    if (userId == null) {
      return const Left(
        LocalDatabaseFailure(
          message: 'No current user to load cached applications',
        ),
      );
    }

    try {
      final cached = await localDataSource.getMyApplications(userId);
      if (cached.isNotEmpty) {
        return Right(cached.map((item) => item.toModel().toEntity()).toList());
      }
      return const Left(
        LocalDatabaseFailure(message: 'No cached applications available'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationEntity>>> getGigApplications(
    String gigId,
  ) async {
    final normalizedGigId = gigId.trim();

    if (await networkInfo.isConnected) {
      try {
        final applications = await remoteDataSource.getGigApplications(
          normalizedGigId,
        );
        await _cacheGigApplications(normalizedGigId, applications);
        return Right(applications.map((item) => item.toEntity()).toList());
      } on DioException catch (e) {
        if (!_isConnectivityIssue(e)) {
          return Left(
            ApiFailure.fromDioException(
              e,
              fallback: 'Failed to fetch gig applications',
            ),
          );
        }
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      final cached = await localDataSource.getGigApplications(normalizedGigId);
      if (cached.isNotEmpty) {
        return Right(cached.map((item) => item.toModel().toEntity()).toList());
      }
      return const Left(
        LocalDatabaseFailure(message: 'No cached gig applications available'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> apply(
    String gigId,
    String coverLetter,
  ) async {
    try {
      final created = await remoteDataSource.apply(gigId.trim(), coverLetter);
      await _upsertApplication(created);
      return Right(created.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to apply for gig'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateStatus(
    String applicationId,
    String status,
  ) async {
    try {
      await remoteDataSource.updateStatus(applicationId, status);
      await localDataSource.updateStatus(applicationId, status);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to update application status',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
