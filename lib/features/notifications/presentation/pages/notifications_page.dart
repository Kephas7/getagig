import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/features/notifications/presentation/view_model/notifications_viewmodel.dart';
import 'package:getagig/features/messaging/presentation/pages/chat_page.dart';
import 'package:getagig/features/messaging/presentation/view_model/conversation_initiator_viewmodel.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(notificationsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          "Notifications",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAsRead("all");
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            child: const Text("Mark all read"),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isUnread = !notification.isRead;

                IconData iconData;
                Color iconColor;

                switch (notification.type) {
                  case 'new_message':
                    iconData = Icons.chat_bubble_rounded;
                    iconColor = colorScheme.secondary;
                    break;
                  case 'new_application':
                    iconData = Icons.person_add_alt_1_rounded;
                    iconColor = const Color(0xFF10B981);
                    break;
                  case 'application_accepted':
                    iconData = Icons.check_circle_rounded;
                    iconColor = const Color(0xFF10B981);
                    break;
                  case 'application_rejected':
                    iconData = Icons.cancel_rounded;
                    iconColor = const Color(0xFFEF4444);
                    break;
                  default:
                    iconData = Icons.notifications_rounded;
                    iconColor = AppShellStyles.accent(context);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: AppShellStyles.glassCard(
                    context,
                    radius: 22,
                    tint: isUnread ? iconColor : null,
                    highlighted: isUnread,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        if (isUnread) {
                          ref
                              .read(notificationsProvider.notifier)
                              .markAsRead(notification.id!);
                        }

                        if (notification.type == 'new_message' &&
                            notification.relatedId != null) {
                          _navigateToChat(
                            context,
                            ref,
                            notification.relatedId!,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(iconData, color: iconColor, size: 22),
                                  if (isUnread)
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontWeight: isUnread
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                      fontSize: 16,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.content,
                                    style: TextStyle(
                                      color: AppShellStyles.mutedText(context),
                                      fontSize: 13,
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppShellStyles.mutedSurface(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppShellStyles.border(context)),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: AppShellStyles.accent(context),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "All caught up!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "New activity related to your gigs and\nmessages will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppShellStyles.mutedText(context),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final conversationInitiator = ref.read(
      conversationInitiatorProvider.notifier,
    );

    final result = await conversationInitiator.startConversation(userId);

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (conversation) {
        // Navigate to chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              conversationId: conversation.id ?? '',
              receiverId: userId,
              receiverName: conversation.participants.isNotEmpty
                  ? (conversation.participants.first.username.trim().isNotEmpty
                        ? conversation.participants.first.username
                        : conversation.participants.first.email)
                  : '',
            ),
          ),
        );
      },
    );
  }
}
