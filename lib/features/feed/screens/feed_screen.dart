import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/optimized_image.dart';
import '../../../core/widgets/quad_avatar.dart';
import '../../../core/widgets/quad_card.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../models/post_model.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('QuadConnect'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildCreatePostCard(context, ref, authState),
            ),
            if (feedState.isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const PostCardSkeleton(),
                  childCount: 5,
                ),
              )
            else if (feedState.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error loading feed', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(feedState.error!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              )
            else if (feedState.posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.article_outlined, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text('No posts yet', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Be the first to share something!', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPostCard(context, ref, feedState.filteredPosts[index]),
                  childCount: feedState.filteredPosts.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showSearch(context: context, delegate: PostSearchDelegate());
  }

  void _showCreatePostSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Create Post', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await ref.read(feedProvider.notifier).createPost(content: controller.text.trim());
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Post'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostCard(BuildContext context, WidgetRef ref, AuthState authState) {
    return GestureDetector(
      onTap: () => _showCreatePostSheet(context, ref),
      child: QuadCard(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            QuadAvatar(
              imageUrl: authState.user?.photoUrl,
              initials: authState.user?.initials ?? '?',
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  "What's on your mind?",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.image_outlined, color: AppColors.success),
              onPressed: () => _showCreatePostSheet(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, WidgetRef ref, PostModel post) {
    return QuadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              QuadAvatar(
                imageUrl: post.authorPhotoUrl,
                initials: post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(timeago.format(post.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () => _showPostOptions(context, ref, post)),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
          if (post.hasImages) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: OptimizedImage(
                imageUrl: post.imageUrls.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _PostActions(post: post),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context, WidgetRef ref, PostModel post) {
    final authState = ref.read(authNotifierProvider);
    final isAuthor = authState.user?.uid == post.authorId;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAuthor)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Delete Post'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(feedProvider.notifier).deletePost(post.id);
                },
              ),
            ListTile(leading: const Icon(Icons.share), title: const Text('Share'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.flag_outlined), title: const Text('Report'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

/// Widget for post actions (likes, comments, save)
class _PostActions extends ConsumerWidget {
  final PostModel post;
  const _PostActions({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeStatus = ref.watch(postLikeStatusProvider(post.id));
    final isLiked = likeStatus.maybeWhen(data: (v) => v, orElse: () => false);

    return Row(
      children: [
        GestureDetector(
          onTap: () => ref.read(feedProvider.notifier).toggleLike(post.id),
          child: Row(
            children: [
              AnimatedLikeButton(isLiked: isLiked, onTap: () => ref.read(feedProvider.notifier).toggleLike(post.id), size: 20),
              const SizedBox(width: 4),
              Text('${post.likesCount}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isLiked ? AppColors.secondary : AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 24),
        _buildActionButton(context, Icons.chat_bubble_outline, '${post.commentsCount}', AppColors.primary, () => _showComments(context, ref)),
        const SizedBox(width: 24),
        _buildActionButton(context, Icons.share_outlined, 'Share', AppColors.textSecondary, () {}),
        const SizedBox(width: 24),
        _buildActionButton(context, post.isSaved ? Icons.bookmark : Icons.bookmark_border, 'Save', post.isSaved ? AppColors.secondary : AppColors.textSecondary, () {
          ref.read(feedProvider.notifier).toggleSave(post.id);
        }),
      ],
    );
  }

  void _showComments(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(postId: post.id),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// Comments bottom sheet
class _CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const _CommentsSheet({required this.postId});

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(postCommentsProvider(widget.postId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Comments', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: comments.when(
              data: (list) => list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.comment_outlined, size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text('No comments yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Be the first to comment!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final comment = list[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              QuadAvatar(
                                initials: comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?',
                                size: 36,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(comment.authorName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 8),
                                        Text(timeago.format(comment.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(comment.content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () async {
                    if (_controller.text.trim().isNotEmpty) {
                      await ref.read(addCommentProvider)(widget.postId, _controller.text.trim());
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Search delegate for posts
class PostSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search posts, people, topics...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => _SearchResults(query: query);

  @override
  Widget buildSuggestions(BuildContext context) => _SearchResults(query: query);
}

class _SearchResults extends ConsumerWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('Search for posts, people, or topics', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final feedState = ref.watch(feedProvider);
    final searchQuery = query.toLowerCase();

    final results = feedState.posts.where((post) {
      return post.content.toLowerCase().contains(searchQuery) ||
          post.authorName.toLowerCase().contains(searchQuery) ||
          post.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();

    if (results.isEmpty) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
        const SizedBox(height: 16),
        Text(
          'No results for "$query"',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Try different keywords',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}


    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        return QuadCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: QuadAvatar(
              imageUrl: post.authorPhotoUrl,
              initials: post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
              size: 40,
            ),
            title: Text(post.authorName),
            subtitle: Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              timeago.format(post.createdAt),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            onTap: () {
              // Optionally, navigate to post details
            },
          ),
        );
      },
    );
  }
}
