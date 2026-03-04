import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/features/admin/data/datasources/admin_datasource.dart';
import 'package:getagig/features/admin/data/models/admin_user_model.dart';

final adminRemoteDataSourceProvider = Provider<IAdminRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AdminRemoteDataSource(apiClient: apiClient);
});

class AdminRemoteDataSource implements IAdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<AdminUserModel> createUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminUsers,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        return AdminUserModel.fromJson(data);
      }
    }

    throw Exception(
      response.data['message']?.toString() ?? 'Failed to create user',
    );
  }

  @override
  Future<List<AdminUserModel>> getUsers({int page = 1, int limit = 100}) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminUsers,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.data['success'] == true) {
      final responseData = response.data['data'];
      final List<dynamic> usersJson;

      if (responseData is Map<String, dynamic>) {
        usersJson = responseData['users'] as List<dynamic>? ?? [];
      } else if (responseData is List<dynamic>) {
        usersJson = responseData;
      } else {
        usersJson = [];
      }

      return usersJson
          .whereType<Map>()
          .map(
            (user) => AdminUserModel.fromJson(Map<String, dynamic>.from(user)),
          )
          .toList();
    }

    throw Exception(
      response.data['message']?.toString() ?? 'Failed to fetch users',
    );
  }

  @override
  Future<void> setVerificationStatus({
    required String userId,
    required String role,
    required bool isVerified,
    String? rejectionReason,
  }) async {
    final normalizedRole = role.toLowerCase();
    if (normalizedRole != 'musician' && normalizedRole != 'organizer') {
      throw Exception('Only musician and organizer users can be verified.');
    }

    final endpoint = normalizedRole == 'musician'
        ? ApiEndpoints.musicianVerify
        : ApiEndpoints.organizerVerify;

    final response = await _apiClient.patch(
      endpoint,
      data: {
        'userId': userId,
        'isVerified': isVerified,
        if (rejectionReason != null && rejectionReason.trim().isNotEmpty)
          'rejectionReason': rejectionReason.trim(),
      },
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['message']?.toString() ??
            'Failed to update verification status',
      );
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.adminUserById(userId),
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['message']?.toString() ?? 'Failed to delete user',
      );
    }
  }

  @override
  Future<AdminUserModel> updateUser({
    required String userId,
    required String username,
    required String email,
    required String role,
    String? password,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.adminUserById(userId),
      data: {
        'username': username,
        'email': email,
        'role': role,
        if (password != null && password.trim().isNotEmpty)
          'password': password.trim(),
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        return AdminUserModel.fromJson(data);
      }
    }

    throw Exception(
      response.data['message']?.toString() ?? 'Failed to update user',
    );
  }
}
