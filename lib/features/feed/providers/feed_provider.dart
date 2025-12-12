import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final String? lastPostId; // replaced DocumentSnapshot
  final String searchQuery;
  final String? selectedCategory;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.lastPostId,
    this.searchQuery = '',
    this.selectedCategory,
  });

  List<PostModel> get filteredPosts {
    var filtered = posts;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
          p.content.toLowerCase().contains(query) ||
          p.authorName.toLowerCase().contains(query)).toList();
    }

    if (selectedCategory != null) {
      filtered = filtered.where((p) => p.tags.contains(selectedCategory)).toList();
    }

    return filtered;
  }

  List<PostModel> get savedPosts =>
      posts.where((p) => p.isSaved).toList();

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
    String? lastPostId,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      lastPostId: lastPostId ?? this.lastPostId,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}

class FeedNotifier extends Notifier<FeedState> {
  late FirestoreService _firestoreService;

  @override
  FeedState build() {
    _firestoreService = ref.watch(firestoreServiceProvider);
    _subscribeToFeed();
    return const FeedState(isLoading: true);
  }

  void _subscribeToFeed() {
    _firestoreService.streamFeed().listen(
      (posts) {
        final lastId = posts.isNotEmpty ? posts.last.id : null;
        state = state.copyWith(posts: posts, isLoading: false, hasMore: posts.length >= 20, lastPostId: lastId);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setCategory(String? category) => state = state.copyWith(selectedCategory: category);
  void clearFilters() => state = state.copyWith(searchQuery: '', clearCategory: true);

  Future<void> createPost({required String content, List<String> imageUrls = const [], List<String> tags = const [], PostType type = PostType.text}) async {
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
        'savedBy': [],
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to create post: $e');
    }
  }

  Future<void> toggleLike(String postId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;
    final userId = authState.user!.uid;
    final isLiked = await _firestoreService.hasLiked(postId, userId);
    await _firestoreService.toggleLike(postId, userId, isLiked);
  }

  Future<void> toggleSave(String postId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final postIndex = state.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final isSaved = post.isSaved;
    await _firestoreService.toggleSave(postId, authState.user!.uid, isSaved);

    final updatedPosts = [...state.posts];
    updatedPosts[postIndex] = post.copyWith(isSaved: !isSaved);
    state = state.copyWith(posts: updatedPosts);
  }

  Future<void> deletePost(String postId) async => _firestoreService.deletePost(postId);
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(() => FeedNotifier());

final postLikeStatusProvider = StreamProvider.family<bool, String>((ref, postId) {
  final authState = ref.watch(authNotifierProvider);
  if (authState.user == null) return Stream.value(false);
  return ref.watch(firestoreServiceProvider).streamLikeStatus(postId, authState.user!.uid);
});

final postCommentsProvider = StreamProvider.family<List<CommentModel>, String>((ref, postId) {
  return ref.watch(firestoreServiceProvider).streamComments(postId).map((snapshot) =>
      snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList());
});

final addCommentProvider = Provider((ref) {
  return (String postId, String content) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;
    final user = authState.user!;
    await ref.read(firestoreServiceProvider).addComment(postId, {
      'authorId': user.uid,
      'authorName': user.displayName,
      'authorPhotoUrl': user.photoUrl,
      'content': content,
      'likesCount': 0,
    });
  };
});
