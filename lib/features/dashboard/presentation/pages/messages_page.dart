import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/dashboard/presentation/view_model/conversations_viewmodel.dart';
import 'package:getagig/features/dashboard/presentation/pages/chat_page.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsyncValue = ref.watch(conversationsProvider);
    final authUser = ref.read(authViewModelProvider).user;
    final currentUserId = authUser?.userId ?? authUser?.id;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1B61),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: conversationsAsyncValue.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];

                // Find the other participant
                final otherParticipant = conversation.participants.firstWhere(
                  (p) => p.id != currentUserId,
                  orElse: () => conversation.participants.first,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              conversationId: conversation.id!,
                              receiverId: otherParticipant.id!,
                              receiverName: otherParticipant.username,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.1),
                                    const Color(0xFF1A1B61).withOpacity(0.1)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF1A1B61),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    otherParticipant.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Color(0xFF1A1B61),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    conversation.lastMessage ??
                                        "Start a conversation...",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
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
              color: const Color(0xFF6366F1).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 72,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Inbox is empty",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1B61),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your conversations with musicians\nand organizers will appear here.",
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
}

