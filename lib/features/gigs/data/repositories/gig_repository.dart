import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/services/connectivity/network_info.dart';
import 'package:getagig/core/utils/location_transformer.dart';
import 'package:getagig/features/gigs/data/datasources/local/gig_local_datasource.dart';
import 'package:getagig/features/gigs/data/models/gig_hive_model.dart';
import 'package:getagig/features/gigs/data/models/gig_model.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';

final gigRepositoryProvider = Provider<IGigRepository>((ref) {
  return GigRepository(
    apiClient: ref.read(apiClientProvider),
    localDataSource: ref.read(gigLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class GigRepository implements IGigRepository {
  final ApiClient _apiClient;
  final IGigLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  GigRepository({
    required ApiClient apiClient,
    required IGigLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _apiClient = apiClient,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

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

  Future<void> _cacheGigs(List<GigEntity> gigs, {bool replace = true}) async {
    try {
      final hiveModels = gigs.map(GigHiveModel.fromEntity).toList();
      await _localDataSource.saveGigs(hiveModels, replace: replace);
    } catch (_) {
      // Cache failures should not block successful API flows.
    }
  }

  Future<void> _cacheGig(GigEntity gig) async {
    try {
      await _localDataSource.upsertGig(GigHiveModel.fromEntity(gig));
    } catch (_) {
      // Cache failures should not block successful API flows.
    }
  }

  Future<Either<Failure, List<GigEntity>>> _readCachedGigs({
    String? organizerId,
  }) async {
    try {
      final cached = await _localDataSource.getGigs(organizerId: organizerId);
      if (cached.isNotEmpty) {
        return Right(cached.map((gig) => gig.toEntity()).toList());
      }
      return const Left(
        LocalDatabaseFailure(message: 'No cached gigs available'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, GigEntity>> _readCachedGigById(String id) async {
    try {
      final cached = await _localDataSource.getGigById(id);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: 'No cached gig available'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GigEntity>>> getAllGigs({
    String? organizerId,
  }) async {
    final trimmedOrganizerId = organizerId?.trim();

    if (await _networkInfo.isConnected) {
      try {
        final queryParameters =
            (trimmedOrganizerId != null && trimmedOrganizerId.isNotEmpty)
            ? <String, dynamic>{'organizerId': trimmedOrganizerId}
            : null;

        final response = await _apiClient.get(
          ApiEndpoints.gigs,
          queryParameters: queryParameters,
        );

        if (response.data['success'] == true) {
          final dynamic responseData = response.data['data'];
          List<dynamic> dataList = [];
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('gigs')) {
            dataList = responseData['gigs'] ?? [];
          } else if (responseData is List<dynamic>) {
            dataList = responseData;
          }

          final gigs = dataList
              .map((e) => GigModel.fromJson(_normalizeGigJson(e)).toEntity())
              .toList();

          await _cacheGigs(
            gigs,
            replace: trimmedOrganizerId == null || trimmedOrganizerId.isEmpty,
          );

          return Right(gigs);
        }

        return Left(
          ApiFailure(
            message: response.data['message'] ?? 'Failed to load gigs',
          ),
        );
      } on DioException catch (e) {
        if (!_isConnectivityIssue(e)) {
          return Left(
            ApiFailure.fromDioException(e, fallback: 'Failed to load gigs'),
          );
        }
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    return _readCachedGigs(organizerId: trimmedOrganizerId);
  }

  @override
  Future<Either<Failure, GigEntity>> getGigById(String id) async {
    final gigId = id.trim();

    if (await _networkInfo.isConnected) {
      try {
        final response = await _apiClient.get(ApiEndpoints.gigById(gigId));
        if (response.data['success'] == true) {
          final gig = GigModel.fromJson(
            _normalizeGigJson(response.data['data']),
          ).toEntity();
          await _cacheGig(gig);
          return Right(gig);
        }
        return Left(
          ApiFailure(message: response.data['message'] ?? 'Failed to load gig'),
        );
      } on DioException catch (e) {
        if (!_isConnectivityIssue(e)) {
          return Left(
            ApiFailure.fromDioException(e, fallback: 'Failed to load gig'),
          );
        }
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    return _readCachedGigById(gigId);
  }

  @override
  Future<Either<Failure, GigEntity>> createGig(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.gigs, data: data);
      if (response.data['success'] == true) {
        final gig = GigModel.fromJson(
          _normalizeGigJson(response.data['data']),
        ).toEntity();
        await _cacheGig(gig);
        return Right(gig);
      }
      return Left(
        ApiFailure(message: response.data['message'] ?? 'Failed to create gig'),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to create gig'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GigEntity>> updateGig(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.gigById(id),
        data: data,
      );
      if (response.data['success'] == true) {
        final gig = GigModel.fromJson(
          _normalizeGigJson(response.data['data']),
        ).toEntity();
        await _cacheGig(gig);
        return Right(gig);
      }
      return Left(
        ApiFailure(message: response.data['message'] ?? 'Failed to update gig'),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to update gig'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGig(String id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.gigById(id));
      if (response.data['success'] == true) {
        await _localDataSource.deleteGig(id);
        return const Right(null);
      }
      return Left(
        ApiFailure(message: response.data['message'] ?? 'Failed to delete gig'),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to delete gig'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Map<String, dynamic> _normalizeGigJson(dynamic data) {
    final json = Map<String, dynamic>.from(data as Map);
    final parsedLocation = LocationTransformer.parse(json['location']);
    json['location'] = LocationTransformer.compose(
      city: (parsedLocation['city'] ?? '').toString(),
      state: (parsedLocation['state'] ?? '').toString(),
      country: (parsedLocation['country'] ?? '').toString(),
    );
    return json;
  }
}
