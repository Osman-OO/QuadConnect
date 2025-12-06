import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

/// State for the feed
class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final String searchQuery;
  final String? selectedCategory;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.lastDocument,
    this.searchQuery = '',
    this.selectedCategory,
  });

  /// Get filtered posts based on search and category
  List<PostModel> get filteredPosts {
    var filtered = posts;

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((post) {
        return post.content.toLowerCase().contains(query) ||
            post.authorName.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by tag/category
    if (selectedCategory != null) {
      filtered = filtered
          .where((post) => post.tags.contains(selectedCategory))
          .toList();
    }

    return filtered;
  }

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
    DocumentSnapshot? lastDocument,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
    );
  }
}

/// Manages the feed state and operations
class FeedNotifier extends Notifier<FeedState> {
  late FirestoreService _firestoreService;

  @override
  FeedState build() {
    _firestoreService = ref.watch(firestoreServiceProvider);
    // Start listening to feed when provider is created
    _subscribeToFeed();
    return const FeedState(isLoading: true);
  }

  void _subscribeToFeed() {
    _firestoreService.streamFeed().listen(
      (snapshot) {
        final posts = snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList();
        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasMore: posts.length >= 20,
          lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        );
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  /// Set search query for filtering posts
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Set category filter
  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(searchQuery: '', clearCategory: true);
  }

  /// Create a new post
  Future<void> createPost({
    required String content,
    List<String> imageUrls = const [],
    List<String> tags = const [],
    PostType type = PostType.text,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final user = authState.user!;
    try {
      await _firestoreService.createPost({
        'authorId': user.uid,
        'authorName': user.displayName,
        'authorPhotoUrl': user.photoUrl,
        'content': content,
        'type': type.name,
        'imageUrls': imageUrls,
        'tags': tags,
        'likesCount': 0,
        'commentsCount': 0,
        'sharesCount': 0,
        'isPinned': false,
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to create post: $e');
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final userId = authState.user!.uid;
    final isLiked = await _firestoreService.hasLiked(postId, userId);
    await _firestoreService.toggleLike(postId, userId, isLiked);
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _firestoreService.deletePost(postId);
  }
}

/// Provider for feed
final feedProvider = NotifierProvider<FeedNotifier, FeedState>(() {
  return FeedNotifier();
});

/// Stream provider for checking if user liked a specific post
final postLikeStatusProvider = StreamProvider.family<bool, String>((
  ref,
  postId,
) {
  final authState = ref.watch(authNotifierProvider);
  if (authState.user == null) return Stream.value(false);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamLikeStatus(postId, authState.user!.uid);
});

/// Stream provider for post comments
final postCommentsProvider = StreamProvider.family<List<CommentModel>, String>((
  ref,
  postId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService
      .streamComments(postId)
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList(),
      );
});

/// Add a comment
final addCommentProvider = Provider((ref) {
  return (String postId, String content) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final user = authState.user!;
    final firestoreService = ref.read(firestoreServiceProvider);

    await firestoreService.addComment(postId, {
      'authorId': user.uid,
      'authorName': user.displayName,
      'authorPhotoUrl': user.photoUrl,
      'content': content,
      'likesCount': 0,
    });
  };
});
