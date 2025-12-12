import 'package:cloud_firestore/cloud_firestore.dart';


/// Types of posts in the feed
enum PostType { text, image, event, poll }

/// A post in the QuadConnect feed
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final PostType type;
  final List<String> imageUrls;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> tags;
  final String? linkedEventId;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime? editedAt;

  /// NEW: Indicates whether the user has saved this post
  final bool isSaved;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.type = PostType.text,
    this.imageUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.tags = const [],
    this.linkedEventId,
    this.isPinned = false,
    required this.createdAt,
    this.editedAt,
    this.isSaved = false, // default false
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      type: PostType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PostType.text,
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      sharesCount: data['sharesCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      linkedEventId: data['linkedEventId'],
      isPinned: data['isPinned'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      isSaved: data['isSaved'] ?? false, // read from Firestore if exists
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'type': type.name,
      'imageUrls': imageUrls,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'tags': tags,
      'linkedEventId': linkedEventId,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'isSaved': isSaved, // store in Firestore
    };
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    PostType? type,
    List<String>? imageUrls,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    List<String>? tags,
    String? linkedEventId,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? editedAt,
    bool? isSaved, // new field
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrls: imageUrls ?? this.imageUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      tags: tags ?? this.tags,
      linkedEventId: linkedEventId ?? this.linkedEventId,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  bool get hasImages => imageUrls.isNotEmpty;
  bool get wasEdited => editedAt != null;
}
