import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Handles all messaging operations
/// Real-time chat with typing indicators and read receipts
class MessageService {
  final FirebaseFirestore _db;

  MessageService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _conversations => _db.collection('conversations');

  // ══════════════════════════════════════════════════════════════════════════
  // CONVERSATION OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get or create a conversation between two users
  Future<String> getOrCreateConversation(
    String userId1,
    String userId2, {
    String? user1Name,
    String? user2Name,
  }) async {
    // Sort IDs to ensure consistent conversation ID
    final participants = [userId1, userId2]..sort();
    final conversationId = '${participants[0]}_${participants[1]}';

    final doc = await _conversations.doc(conversationId).get();
    if (!doc.exists) {
      await _conversations.doc(conversationId).set({
        'participants': participants,
        'participantNames': {
          userId1: user1Name ?? 'User',
          userId2: user2Name ?? 'User',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageAt': null,
        'typing': {},
        'unreadCounts': {},
      });
    }

    return conversationId;
  }

  /// Stream user's conversations
  /// Note: Sorting is done client-side to avoid needing composite indexes
  Stream<QuerySnapshot> streamConversations(String userId) {
    return _conversations
        .where('participants', arrayContains: userId)
        .snapshots();
  }

  /// Stream messages in a conversation
  Stream<QuerySnapshot> streamMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    final messageData = {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'sentAt': FieldValue.serverTimestamp(),
      'readBy': [senderId],
    };

    // Add message to subcollection
    await _conversations
        .doc(conversationId)
        .collection('messages')
        .add(messageData);

    // Update conversation's last message
    await _conversations.doc(conversationId).update({
      'lastMessage': text.length > 50 ? '${text.substring(0, 50)}...' : text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId, String oderId) async {
    final unreadMessages = await _conversations
        .doc(conversationId)
        .collection('messages')
        .where(
          'readBy',
          whereNotIn: [
            [oderId],
          ],
        )
        .get();

    final batch = _db.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        'readBy': FieldValue.arrayUnion([oderId]),
      });
    }
    await batch.commit();
  }

  /// Set typing indicator
  Future<void> setTyping(
    String conversationId,
    String oderId,
    bool isTyping,
  ) async {
    await _conversations.doc(conversationId).update({
      'typing.$oderId': isTyping,
    });
  }

  /// Stream typing status
  Stream<Map<String, dynamic>> streamTypingStatus(String conversationId) {
    return _conversations.doc(conversationId).snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['typing'] as Map<String, dynamic>? ?? {};
    });
  }

  /// Get unread count for a user
  Stream<int> streamUnreadCount(String oderId) {
    return _conversations
        .where('participants', arrayContains: oderId)
        .snapshots()
        .asyncMap((snapshot) async {
          int total = 0;
          for (final doc in snapshot.docs) {
            final messages = await doc.reference
                .collection('messages')
                .where('senderId', isNotEqualTo: oderId)
                .get();

            for (final msg in messages.docs) {
              final readBy = List<String>.from(msg.data()['readBy'] ?? []);
              if (!readBy.contains(oderId)) total++;
            }
          }
          return total;
        });
  }

  /// Delete a conversation (soft delete - just remove from user's view)
  Future<void> leaveConversation(String conversationId, String oderId) async {
    await _conversations.doc(conversationId).update({
      'hiddenFor': FieldValue.arrayUnion([oderId]),
    });
  }
}

// Provider
final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});
