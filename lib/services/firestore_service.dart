import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/feed/models/post_model.dart';
import '../features/feed/models/comment_model.dart';
import '../features/events/models/event_model.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // Collections
  CollectionReference get users => _db.collection('users');
  CollectionReference get posts => _db.collection('posts');
  CollectionReference get events => _db.collection('events');

  // ✅ Added clubs collection
  CollectionReference get clubs => _db.collection('clubs');

  /// ---------------------- POSTS ----------------------

  Future<DocumentReference> createPost(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    return posts.add(data);
  }

  Future<void> deletePost(String postId) async {
    await posts.doc(postId).delete();
  }

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

  Future<bool> hasLiked(String postId, String userId) async {
    final doc = await posts.doc(postId).collection('likes').doc(userId).get();
    return doc.exists;
  }

  Future<void> toggleSave(String postId, String userId, bool isSaved) async {
    final saveRef = posts.doc(postId).collection('saves').doc(userId);
    if (isSaved) {
      await saveRef.delete();
    } else {
      await saveRef.set({'savedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<bool> hasSaved(String postId, String userId) async {
    final doc = await posts.doc(postId).collection('saves').doc(userId).get();
    return doc.exists;
  }

  Stream<List<PostModel>> streamFeed({int limit = 20}) {
    return posts
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  Stream<bool> streamLikeStatus(String postId, String userId) {
    return posts
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<QuerySnapshot> streamComments(String postId) {
    return posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> addComment(String postId, Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    await posts.doc(postId).collection('comments').add(data);
    await posts.doc(postId).update({'commentsCount': FieldValue.increment(1)});
  }

  /// ---------------------- EVENTS ----------------------

  Stream<List<EventModel>> streamUpcomingEvents({int limit = 20, String? category}) {
    Query q = events.orderBy('startTime').limit(limit);

    if (category != null) {
      q = q.where('category', isEqualTo: category);
    }

    return q.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList(),
    );
  }

  Future<DocumentReference> createEvent(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    return events.add(data);
  }

  Future<void> rsvpEvent(String eventId, String userId, bool attending) async {
    final rsvpRef = events.doc(eventId).collection('rsvps').doc(userId);
    if (attending) {
      await rsvpRef.set({
        'attending': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await rsvpRef.delete();
    }
  }

  Stream<bool> streamRsvpStatus(String eventId, String userId) {
    return events
        .doc(eventId)
        .collection('rsvps')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// ---------------------- USERS ----------------------

  Future<DocumentSnapshot?> findUserByEmail(String email) async {
    final query = await users.where('email', isEqualTo: email).limit(1).get();
    if (query.docs.isNotEmpty) return query.docs.first;
    return null;
  }
}

/// Riverpod provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
