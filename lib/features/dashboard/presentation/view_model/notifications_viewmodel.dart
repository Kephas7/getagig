import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/dashboard/data/models/notification_model.dart';
import 'package:getagig/features/dashboard/data/repositories/notification_repository.dart';
import 'package:getagig/core/services/socket_service.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(() {
  return NotificationsNotifier();
});

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  Future<List<NotificationModel>> build() async {
    // Listen for new real-time notifications
    _subscription ??=
        ref.read(socketServiceProvider).notificationStream.listen((data) {
      final newNotification = NotificationModel.fromJson(data);
      state = AsyncData([newNotification, ...state.value ?? []]);
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return _fetchNotifications();
  }

  Future<List<NotificationModel>> _fetchNotifications() async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.getNotifications();
    return result.fold(
      (failure) => throw failure.message,
      (notifications) => notifications,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotifications());
  }

  Future<void> markAsRead(String notificationId) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAsRead(notificationId);

    result.fold(
      (failure) => print(failure.message),
      (_) {
        final currentList = state.value ?? [];
        if (notificationId == "all") {
          state = AsyncData(currentList.map((n) => n.copyWith(isRead: true)).toList());
        } else {
          state = AsyncData(currentList.map((n) {
            return n.id == notificationId ? n.copyWith(isRead: true) : n;
          }).toList());
        }
      },
    );
  }
}
