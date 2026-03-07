import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/notifications/data/models/notification_model.dart';
import 'package:getagig/features/notifications/data/repositories/notification_repository.dart';
import 'package:getagig/core/services/socket_service.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(() {
      return NotificationsNotifier();
    });

final unreadMessageNotificationCountProvider = Provider<int>((ref) {
  return ref
      .watch(notificationsProvider)
      .maybeWhen(
        data: (notifications) => notifications
            .where(
              (notification) =>
                  !notification.isRead && notification.type == 'new_message',
            )
            .length,
        orElse: () => 0,
      );
});

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  String? _currentUserId() {
    final user = ref.read(authViewModelProvider).user;
    return user?.userId ?? user?.id;
  }

  bool _belongsToCurrentUser(NotificationModel notification) {
    final currentUserId = _currentUserId();
    if (currentUserId == null || currentUserId.isEmpty) return true;

    final ownerId = notification.userId?.trim();
    if (ownerId == null || ownerId.isEmpty) return false;

    return ownerId == currentUserId;
  }

  @override
  Future<List<NotificationModel>> build() async {
    // Listen for new real-time notifications
    _subscription ??= ref.read(socketServiceProvider).notificationStream.listen((
      data,
    ) {
      final newNotification = NotificationModel.fromJson(data);

      // Defensive ownership check: prevents showing notifications not meant for
      // the current user when socket payloads are misrouted.
      if (!_belongsToCurrentUser(newNotification)) {
        return;
      }

      final current = state.value ?? const <NotificationModel>[];
      if (newNotification.id != null &&
          current.any((n) => n.id == newNotification.id)) {
        return;
      }

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
      (notifications) => notifications.where(_belongsToCurrentUser).toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotifications());
  }

  Future<void> markAsRead(String notificationId) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAsRead(notificationId);

    result.fold((failure) => print(failure.message), (_) {
      final currentList = state.value ?? [];
      if (notificationId == "all") {
        state = AsyncData(
          currentList.map((n) => n.copyWith(isRead: true)).toList(),
        );
      } else {
        state = AsyncData(
          currentList.map((n) {
            return n.id == notificationId ? n.copyWith(isRead: true) : n;
          }).toList(),
        );
      }
    });
  }
}
