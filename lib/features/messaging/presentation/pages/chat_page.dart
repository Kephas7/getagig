import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:getagig/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:getagig/features/messaging/presentation/view_model/chat_viewmodel.dart';
import 'package:getagig/features/messaging/presentation/view_model/conversations_viewmodel.dart';

enum _ConversationAction { clear, delete }

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isClearing = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isClearing || _isDeleting) return;

    ref
        .read(chatStateProvider(widget.conversationId).notifier)
        .sendMessage(widget.receiverId, text);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: isDestructive
                  ? FilledButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _clearConversation() async {
    if (_isClearing || _isDeleting) return;

    final confirmed = await _confirmAction(
      title: 'Clear conversation?',
      message: 'This will remove all messages from this chat.',
      confirmLabel: 'Clear',
    );
    if (!confirmed || !mounted) return;

    setState(() => _isClearing = true);

    try {
      await ref
          .read(chatStateProvider(widget.conversationId).notifier)
          .clearConversation();
      await ref.read(conversationsProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Conversation cleared.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear conversation: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  Future<void> _deleteConversation() async {
    if (_isClearing || _isDeleting) return;

    final confirmed = await _confirmAction(
      title: 'Delete conversation?',
      message: 'This permanently deletes this chat and all messages.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await ref
          .read(chatStateProvider(widget.conversationId).notifier)
          .deleteConversation();
      await ref.read(conversationsProvider.notifier).refresh();

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete conversation: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsyncValue = ref.watch(
      chatStateProvider(widget.conversationId),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = AppShellStyles.isDark(context);
    final authUser = ref.read(authViewModelProvider).user;
    final currentUserId = authUser?.userId ?? authUser?.id;

    ref.listen(chatStateProvider(widget.conversationId), (previous, next) {
      final previousLength = previous?.whenData((m) => m.length).value ?? 0;
      final nextLength = next.whenData((m) => m.length).value ?? 0;
      if (nextLength > previousLength) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppShellStyles.mutedSurface(context),
              child: Icon(
                Icons.person,
                color: AppShellStyles.mutedText(context),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.receiverName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          if (_isClearing || _isDeleting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            ),
          PopupMenuButton<_ConversationAction>(
            enabled: !_isClearing && !_isDeleting,
            onSelected: (action) {
              switch (action) {
                case _ConversationAction.clear:
                  _clearConversation();
                  break;
                case _ConversationAction.delete:
                  _deleteConversation();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<_ConversationAction>(
                value: _ConversationAction.clear,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.cleaning_services_outlined),
                  title: Text('Clear conversation'),
                ),
              ),
              PopupMenuItem<_ConversationAction>(
                value: _ConversationAction.delete,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete conversation'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsyncValue.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Say hi!',
                      style: TextStyle(
                        color: AppShellStyles.mutedText(context),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.76,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? (isDark
                                    ? const Color(0xFF2A3346)
                                    : const Color(0xFFE9F1FF))
                              : AppShellStyles.mutedSurface(context),
                          border: Border.all(
                            color: isMe
                                ? Colors.transparent
                                : AppShellStyles.border(context),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: isMe
                                ? const Radius.circular(18)
                                : const Radius.circular(4),
                            bottomRight: isMe
                                ? const Radius.circular(4)
                                : const Radius.circular(18),
                          ),
                        ),
                        child: Text(
                          message.content,
                          style: TextStyle(
                            color: isMe
                                ? (isDark
                                      ? const Color(0xFFE9F1FF)
                                      : const Color(0xFF1E2D4A))
                                : colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: AppShellStyles.glassCard(context, radius: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: AppShellStyles.mutedText(context),
                        ),
                        filled: true,
                        fillColor: AppShellStyles.mutedSurface(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _isClearing || _isDeleting ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: _isClearing || _isDeleting
                            ? AppShellStyles.mutedText(context)
                            : colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: isDark
                            ? const Color(0xFF0E1118)
                            : const Color(0xFFFFFFFF),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
