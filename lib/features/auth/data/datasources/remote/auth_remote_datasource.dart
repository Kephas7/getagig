import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:getagig/features/auth/data/datasources/auth_datasource.dart';
import 'package:getagig/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final jsonResponse = response.data as Map<String, dynamic>;
      final responseData = jsonResponse['data'] as Map<String, dynamic>? ?? {};
      final userData = responseData['user'] as Map<String, dynamic>? ?? {};
      final token = responseData['token'] as String? ?? '';

      // Normalize id/_id so AuthApiModel can always read it
      final normalizedUserData = {
        ...userData,
        '_id': userData['_id'] ?? userData['id'],
        'token': token,
      };
      final user = AuthApiModel.fromJson(normalizedUserData);

      await _userSessionService.saveUserSession(
        userId: user.id ?? '',
        email: user.email,
        username: user.username,
        role: user.role,
        token: token,
      );

      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }
    return user;
  }

  @override
  Future<AuthApiModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getCurrentUser);

      if (response.data['success'] == true) {
        final jsonResponse = response.data as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>? ?? {};

        // Normalize id/_id for current user as well
        final normalizedData = {
          ...data,
          '_id': data['_id'] ?? data['id'],
        };
        final user = AuthApiModel.fromJson(normalizedData);

        await _userSessionService.saveUserSession(
          userId: user.id ?? '',
          email: user.email,
          username: user.username,
          role: user.role,
        );

        return user;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // Try to unregister device token on backend
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await _apiClient.delete(
            '/auth/me/device-token',
            data: {'token': token},
          );
        }
      } catch (e) {
        // ignore failures to unregister token
      }

      await _userSessionService.clearSession();
      return true;
    } catch (e) {
      return false;
    }
  }
}
