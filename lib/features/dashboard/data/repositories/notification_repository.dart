import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/api/api_client.dart';
import 'package:getagig/core/api/api_endpoints.dart';
import 'package:getagig/core/error/failures.dart';
import 'package:getagig/core/services/hive_service.dart';
import 'package:getagig/features/dashboard/data/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    apiClient: ref.read(apiClientProvider),
    hiveService: ref.read(hiveServiceProvider),
  );
});

class NotificationRepository {
  final ApiClient _apiClient;
  final HiveService _hiveService;

  NotificationRepository({
    required ApiClient apiClient,
    required HiveService hiveService,
  }) : _apiClient = apiClient,
       _hiveService = hiveService;

  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    final cached = _hiveService.getNotifications();

    try {
      final response = await _apiClient.get(ApiEndpoints.notifications);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final notifications = data
            .map(
              (e) => NotificationModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

        await _hiveService.saveNotifications(notifications);
        return Right(notifications);
      }
      return cached.isNotEmpty
          ? Right(cached)
          : const Left(ApiFailure(message: 'Failed to fetch notifications'));
    } catch (e) {
      if (cached.isNotEmpty) return Right(cached);
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.markNotificationRead(notificationId),
      );
      return Right(response.data['success'] == true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
