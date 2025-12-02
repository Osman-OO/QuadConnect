import 'package:cloud_firestore/cloud_firestore.dart';

/// A conversation between users
class ConversationModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames; // Maps participant ID to name
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final Map<String, bool> typing;
  final Map<String, int> unreadCounts; // Unread count per user
  final bool isGroup;
  final String? groupName;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.participants,
    this.participantNames = const {},
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderId,
    this.typing = const {},
    this.unreadCounts = const {},
    this.isGroup = false,
    this.groupName,
    required this.createdAt,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastSenderId: data['lastSenderId'],
      typing: Map<String, bool>.from(data['typing'] ?? {}),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      isGroup: data['isGroup'] ?? false,
      groupName: data['groupName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Get unread count for a specific user
  int get unreadCount => unreadCounts.values.fold(0, (a, b) => a + b);

  /// Get unread count for specific user
  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;

  /// Get the other participant's info (for 1-on-1 chats)
  Map<String, String?> getOtherParticipant(String myUserId) {
    final otherId = participants.firstWhere(
      (id) => id != myUserId,
      orElse: () => '',
    );
    return {'id': otherId, 'name': participantNames[otherId] ?? 'Unknown User'};
  }

  /// Check if someone is typing
  bool isTypingById(String userId) => typing[userId] ?? false;

  /// Check if anyone other than me is typing
  bool isOtherTyping(String myUserId) {
    return typing.entries.any((e) => e.key != myUserId && e.value);
  }
}
