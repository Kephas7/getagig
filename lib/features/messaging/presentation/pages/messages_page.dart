import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/messaging/presentation/pages/chat_page.dart';
import 'package:getagig/features/messaging/presentation/view_model/conversations_viewmodel.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsyncValue = ref.watch(conversationsProvider);
    final authUser = ref.read(authViewModelProvider).user;
    final currentUserId = authUser?.userId ?? authUser?.id;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: conversationsAsyncValue.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final otherParticipant = conversation.participants.firstWhere(
                  (p) => p.id != currentUserId,
                  orElse: () => conversation.participants.first,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: AppShellStyles.glassCard(
                    context,
                    radius: 22,
                    tint: AppShellStyles.accent(context),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              conversationId: conversation.id!,
                              receiverId: otherParticipant.id!,
                              receiverName: otherParticipant.username,
                            ),
                          ),
                        );

                        if (updated == true && context.mounted) {
                          await ref
                              .read(conversationsProvider.notifier)
                              .refresh();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              height: 58,
                              width: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppShellStyles.mutedSurface(context),
                                border: Border.all(
                                  color: AppShellStyles.border(context),
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: colorScheme.onSurface,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    otherParticipant.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    (conversation.lastMessage
                                                ?.trim()
                                                .isNotEmpty ??
                                            false)
                                        ? conversation.lastMessage!
                                        : 'Start a conversation...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppShellStyles.mutedText(context),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
        error: (err, _) => Center(child: Text('Error: $err')),
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
              Icons.chat_bubble_outline_rounded,
              size: 72,
              color: AppShellStyles.accent(context),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Inbox is empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your conversations with musicians\nand organizers will appear here.',
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
}
