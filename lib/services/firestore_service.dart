import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Central Firestore service for database operations
/// Handles all the heavy lifting so our features stay clean
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  // Collection references - keeping these handy
  CollectionReference get users => _db.collection('users');
  CollectionReference get posts => _db.collection('posts');
  CollectionReference get events => _db.collection('events');
  CollectionReference get conversations => _db.collection('conversations');
  CollectionReference get clubs => _db.collection('clubs');

  // ══════════════════════════════════════════════════════════════════════════
  // USER OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Create or update user profile
  Future<void> setUser(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).set(data, SetOptions(merge: true));
  }

  /// Get user by ID
  Future<DocumentSnapshot> getUser(String uid) async {
    return await users.doc(uid).get();
  }

  /// Stream user changes in real-time
  Stream<DocumentSnapshot> streamUser(String uid) {
    return users.doc(uid).snapshots();
  }

  /// Update user's last active timestamp
  Future<void> updateLastActive(String uid) async {
    await users.doc(uid).update({'lastActive': FieldValue.serverTimestamp()});
  }

  /// Find user by email address
  Future<DocumentSnapshot?> findUserByEmail(String email) async {
    final snapshot = await users
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    }
    return null;
  }

  /// Search users by name or email (for finding people to message)
  Future<List<DocumentSnapshot>> searchUsers(
    String query, {
    int limit = 10,
  }) async {
    final lowerQuery = query.toLowerCase().trim();
    // Search by email (exact match)
    final emailResults = await users
        .where('email', isEqualTo: lowerQuery)
        .limit(limit)
        .get();

    if (emailResults.docs.isNotEmpty) {
      return emailResults.docs;
    }

    // If no email match, get all users and filter (simple approach for demo)
    // In production, you'd use Algolia or similar for text search
    final allUsers = await users.limit(50).get();
    return allUsers.docs
        .where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return false;
          final name = (data['displayName'] as String?)?.toLowerCase() ?? '';
          final email = (data['email'] as String?)?.toLowerCase() ?? '';
          return name.contains(lowerQuery) || email.contains(lowerQuery);
        })
        .take(limit)
        .toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // POST OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Create a new post
  Future<DocumentReference> createPost(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    return await posts.add(data);
  }

  /// Get feed posts with pagination
  Stream<QuerySnapshot> streamFeed({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query query = posts.orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.snapshots();
  }

  /// Get posts by a specific user
  Stream<QuerySnapshot> streamUserPosts(String userId, {int limit = 20}) {
    return posts
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Like/unlike a post (toggle)
  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    final likeRef = posts.doc(postId).collection('likes').doc(userId);

    if (isLiked) {
      await likeRef.delete();
      await posts.doc(postId).update({'likesCount': FieldValue.increment(-1)});
    } else {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      await posts.doc(postId).update({'likesCount': FieldValue.increment(1)});
    }
  }

  /// Check if user liked a post
  Future<bool> hasLiked(String postId, String userId) async {
    final doc = await posts.doc(postId).collection('likes').doc(userId).get();
    return doc.exists;
  }

  /// Stream likes status for a post
  Stream<bool> streamLikeStatus(String postId, String userId) {
    return posts
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Add a comment to a post
  Future<DocumentReference> addComment(
    String postId,
    Map<String, dynamic> commentData,
  ) async {
    commentData['createdAt'] = FieldValue.serverTimestamp();
    final ref = await posts.doc(postId).collection('comments').add(commentData);
    await posts.doc(postId).update({'commentsCount': FieldValue.increment(1)});
    return ref;
  }

  /// Stream comments for a post
  Stream<QuerySnapshot> streamComments(String postId) {
    return posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Delete a post (only by author)
  Future<void> deletePost(String postId) async {
    await posts.doc(postId).delete();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EVENT OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Create a new event
  Future<DocumentReference> createEvent(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    return await events.add(data);
  }

  /// Stream all events (no composite index needed)
  /// Filtering is done client-side to avoid Firestore index requirements
  Stream<QuerySnapshot> streamUpcomingEvents({
    String? category,
    int limit = 50,
  }) {
    // Simple query without composite index requirement
    // Sort and filter client-side in the provider
    return events.limit(limit).snapshots();
  }

  /// RSVP to an event
  Future<void> rsvpEvent(
    String eventId,
    String userId,
    bool isAttending,
  ) async {
    final rsvpRef = events.doc(eventId).collection('attendees').doc(userId);

    if (isAttending) {
      await rsvpRef.delete();
      await events.doc(eventId).update({
        'attendeesCount': FieldValue.increment(-1),
      });
    } else {
      await rsvpRef.set({'rsvpAt': FieldValue.serverTimestamp()});
      await events.doc(eventId).update({
        'attendeesCount': FieldValue.increment(1),
      });
    }
  }

  /// Check if user is attending an event
  Stream<bool> streamRsvpStatus(String eventId, String userId) {
    return events
        .doc(eventId)
        .collection('attendees')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Get attendees for an event
  Stream<QuerySnapshot> streamAttendees(String eventId) {
    return events.doc(eventId).collection('attendees').snapshots();
  }
}

// Provider for the Firestore service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
