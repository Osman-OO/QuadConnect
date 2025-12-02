import 'package:cloud_firestore/cloud_firestore.dart';

/// A single message in a conversation
class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final DateTime sentAt;
  final List<String> readBy;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageUrl,
    required this.sentAt,
    this.readBy = const [],
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'sentAt': Timestamp.fromDate(sentAt),
      'readBy': readBy,
    };
  }

  /// Check if the message has been read by a specific user
  bool isReadBy(String userId) => readBy.contains(userId);

  /// Check if this is my message
  bool isMine(String myUserId) => senderId == myUserId;
}

