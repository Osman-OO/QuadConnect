import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/message_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// State for messages
class MessagesState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;

  const MessagesState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  MessagesState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Manages conversations and messages
class MessagesNotifier extends Notifier<MessagesState> {
  late MessageService _messageService;

  @override
  MessagesState build() {
    _messageService = ref.watch(messageServiceProvider);
    _subscribeToConversations();
    return const MessagesState(isLoading: true);
  }

  void _subscribeToConversations() {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    _messageService
        .streamConversations(authState.user!.uid)
        .listen(
          (snapshot) {
            final conversations = snapshot.docs
                .map((doc) => ConversationModel.fromFirestore(doc))
                .toList();
            state = state.copyWith(
              conversations: conversations,
              isLoading: false,
            );
          },
          onError: (error) {
            state = state.copyWith(isLoading: false, error: error.toString());
          },
        );
  }

  /// Start a new conversation with a user
  Future<String> startConversation(String otherUserId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) throw Exception('Not authenticated');

    return await _messageService.getOrCreateConversation(
      authState.user!.uid,
      otherUserId,
    );
  }

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final user = authState.user!;
    await _messageService.sendMessage(
      conversationId: conversationId,
      senderId: user.uid,
      senderName: user.displayName,
      text: text,
      imageUrl: imageUrl,
    );
  }

  /// Mark conversation as read
  Future<void> markAsRead(String conversationId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    await _messageService.markAsRead(conversationId, authState.user!.uid);
  }

  /// Set typing indicator
  Future<void> setTyping(String conversationId, bool isTyping) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    await _messageService.setTyping(
      conversationId,
      authState.user!.uid,
      isTyping,
    );
  }
}

/// Provider for messages
final messagesProvider = NotifierProvider<MessagesNotifier, MessagesState>(() {
  return MessagesNotifier();
});

/// Stream messages in a conversation
final conversationMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
      final messageService = ref.watch(messageServiceProvider);
      return messageService
          .streamMessages(conversationId)
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => MessageModel.fromFirestore(doc))
                .toList(),
          );
    });

/// Stream typing status
final typingStatusProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, conversationId) {
      final messageService = ref.watch(messageServiceProvider);
      return messageService.streamTypingStatus(conversationId);
    });

/// Total unread count across all conversations
final unreadCountProvider = StreamProvider<int>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState.user == null) return Stream.value(0);

  final messageService = ref.watch(messageServiceProvider);
  return messageService.streamUnreadCount(authState.user!.uid);
});
