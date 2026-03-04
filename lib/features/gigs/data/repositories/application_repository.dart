import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/utils/location_transformer.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/features/gigs/data/models/application_model.dart';
import 'package:getagig/features/gigs/domain/repositories/application_repository.dart';

final applicationRepositoryProvider = Provider<IApplicationRepository>((ref) {
  return ApplicationRepository(apiClient: ref.read(apiClientProvider));
});

class ApplicationRepository implements IApplicationRepository {
  final ApiClient _apiClient;

  ApplicationRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Either<Failure, List<ApplicationModel>>> getMyApplications() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myApplications);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return Right(
          data
              .map(
                (e) => ApplicationModel.fromJson(_normalizeApplicationJson(e)),
              )
              .toList(),
        );
      }
      return const Left(ApiFailure(message: 'Failed to fetch applications'));
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to fetch applications',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationModel>>> getGigApplications(
    String gigId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.gigApplications(gigId),
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return Right(
          data
              .map(
                (e) => ApplicationModel.fromJson(_normalizeApplicationJson(e)),
              )
              .toList(),
        );
      }
      return const Left(
        ApiFailure(message: 'Failed to fetch gig applications'),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to fetch gig applications',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationModel>> apply(
    String gigId,
    String coverLetter,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.applications,
        data: {'gigId': gigId, 'coverLetter': coverLetter},
      );
      if (response.data['success'] == true) {
        return Right(
          ApplicationModel.fromJson(
            _normalizeApplicationJson(response.data['data']),
          ),
        );
      }
      return const Left(ApiFailure(message: 'Failed to apply for gig'));
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
      final response = await _apiClient.put(
        ApiEndpoints.updateApplicationStatus(applicationId),
        data: {'status': status},
      );
      if (response.data['success'] == true) {
        return const Right(true);
      }
      return const Left(
        ApiFailure(message: 'Failed to update application status'),
      );
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

  Map<String, dynamic> _normalizeApplicationJson(dynamic data) {
    final json = Map<String, dynamic>.from(data as Map);
    final gig = json['gig'];

    if (gig is Map) {
      final gigJson = Map<String, dynamic>.from(gig);
      final parsedLocation = LocationTransformer.parse(gigJson['location']);
      gigJson['location'] = LocationTransformer.compose(
        city: (parsedLocation['city'] ?? '').toString(),
        state: (parsedLocation['state'] ?? '').toString(),
        country: (parsedLocation['country'] ?? '').toString(),
      );
      json['gig'] = gigJson;
    }

    return json;
  }
}
