import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/gigs/data/models/gig_model.dart';
import 'package:getagig/features/gigs/domain/entities/gig_entity.dart';
import 'package:getagig/features/gigs/domain/repositories/gig_repository.dart';
import '../../../../core/error/failures.dart';

final gigRepositoryProvider = Provider<IGigRepository>((ref) {
  return GigRepository(apiClient: ref.read(apiClientProvider));
});

class GigRepository implements IGigRepository {
  final ApiClient _apiClient;

  GigRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Either<Failure, List<GigEntity>>> getAllGigs() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.gigs);
      if (response.data['success'] == true) {
        final dynamic responseData = response.data['data'];
        List<dynamic> dataList = [];
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('gigs')) {
          dataList = responseData['gigs'] ?? [];
        } else if (responseData is List<dynamic>) {
          dataList = responseData;
        }
        final gigs = dataList.map((e) => GigModel.fromJson(e).toEntity()).toList();
        return Right(gigs);
      }
      return Left(ApiFailure(message: response.data['message'] ?? 'Failed to load gigs'));
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to load gigs'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GigEntity>> getGigById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.gigById(id));
      if (response.data['success'] == true) {
        return Right(GigModel.fromJson(response.data['data']).toEntity());
      }
      return Left(ApiFailure(message: response.data['message'] ?? 'Failed to load gig'));
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to load gig'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GigEntity>> createGig(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.gigs,
        data: data,
      );
      if (response.data['success'] == true) {
        return Right(GigModel.fromJson(response.data['data']).toEntity());
      }
      return Left(ApiFailure(message: response.data['message'] ?? 'Failed to create gig'));
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to create gig'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GigEntity>> updateGig(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.gigById(id),
        data: data,
      );
      if (response.data['success'] == true) {
        return Right(GigModel.fromJson(response.data['data']).toEntity());
      }
      return Left(ApiFailure(message: response.data['message'] ?? 'Failed to update gig'));
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to update gig'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGig(String id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.gigById(id));
      if (response.data['success'] == true) {
        return const Right(null);
      }
      return Left(ApiFailure(message: response.data['message'] ?? 'Failed to delete gig'));
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to delete gig'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> applyToGig(String gigId, String coverLetter) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.applications,
        data: {
          'gigId': gigId,
          'coverLetter': coverLetter,
        },
      );
      if (response.data['success'] == true) {
        return const Right(null);
      }
      return Left(ApiFailure(message: response.data['message'] ?? 'Failed to apply to gig'));
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioException(e, fallback: 'Failed to apply to gig'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

