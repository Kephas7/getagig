import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/utils/location_transformer.dart';
import 'package:getagig/features/applications/data/datasources/applications_datasource.dart';
import 'package:getagig/features/applications/data/models/application_model.dart';

final applicationsRemoteDataSourceProvider =
    Provider<IApplicationsRemoteDataSource>((ref) {
      return ApplicationsRemoteDataSource(ref.read(apiClientProvider));
    });

class ApplicationsRemoteDataSource implements IApplicationsRemoteDataSource {
  final ApiClient _apiClient;

  ApplicationsRemoteDataSource(this._apiClient);

  @override
  Future<List<ApplicationModel>> getMyApplications() async {
    final response = await _apiClient.get(ApiEndpoints.myApplications);
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((e) => ApplicationModel.fromJson(_normalizeApplicationJson(e)))
          .toList();
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch applications');
  }

  @override
  Future<List<ApplicationModel>> getGigApplications(String gigId) async {
    final response = await _apiClient.get(ApiEndpoints.gigApplications(gigId));
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((e) => ApplicationModel.fromJson(_normalizeApplicationJson(e)))
          .toList();
    }

    throw Exception(
      response.data['message'] ?? 'Failed to fetch gig applications',
    );
  }

  @override
  Future<ApplicationModel> apply(String gigId, String coverLetter) async {
    final response = await _apiClient.post(
      ApiEndpoints.applications,
      data: {'gigId': gigId, 'coverLetter': coverLetter},
    );

    if (response.data['success'] == true) {
      return ApplicationModel.fromJson(
        _normalizeApplicationJson(response.data['data']),
      );
    }

    throw Exception(response.data['message'] ?? 'Failed to apply for gig');
  }

  @override
  Future<void> updateStatus(String applicationId, String status) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateApplicationStatus(applicationId),
      data: {'status': status},
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Failed to update application status',
      );
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
