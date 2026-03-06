import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/dashboard/presentation/view_model/notifications_viewmodel.dart';
import 'package:getagig/features/dashboard/presentation/pages/chat_page.dart';
import 'package:getagig/features/dashboard/presentation/view_model/conversation_initiator_viewmodel.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1B61),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAsRead("all");
            },
            child: const Text(
              "Mark all read",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isUnread = !notification.isRead;

                IconData iconData;
                Color iconColor;

                switch (notification.type) {
                  case 'new_message':
                    iconData = Icons.chat_bubble_rounded;
                    iconColor = const Color(0xFF6366F1);
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
                    iconColor = const Color(0xFFF59E0B);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? iconColor.withOpacity(0.04)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isUnread
                          ? iconColor.withOpacity(0.12)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
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
                                color: iconColor.withOpacity(0.1),
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
                                          : FontWeight.bold,
                                      fontSize: 16,
                                      color: const Color(0xFF1A1B61),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.content,
                                    style: TextStyle(
                                      color: isUnread
                                          ? Colors.black87
                                          : Colors.grey[500],
                                      fontSize: 13,
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.w400,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "All caught up!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1B61),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "New activity related to your gigs and\nmessages will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black45,
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
