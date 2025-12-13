import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/post_model.dart';
import '../../feed/providers/feed_provider.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeStatus = ref.watch(postLikeStatusProvider(post.id));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─────────────────────────────
            /// Author row + 3-dot menu
            /// ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.authorPhotoUrl != null
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
                  child: post.authorPhotoUrl == null
                      ? Text(
                          post.authorName.isNotEmpty
                              ? post.authorName[0]
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    post.authorName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),

                /// 3-dot menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, ref);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Post content
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            /// Images
            if (post.hasImages)
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post.imageUrls[index],
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.border,
                          width: 200,
                          height: 200,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            /// Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  context,
                  icon: likeStatus.value ?? false
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: '${post.likesCount}',
                  color: likeStatus.value ?? false
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                  onTap: () {
                    ref.read(feedProvider.notifier).toggleLike(post.id);
                  },
                ),

                _buildActionButton(
                  context,
                  icon: Icons.comment_outlined,
                  label: '${post.commentsCount}',
                  onTap: () {
                    _showComments(context);
                  },
                ),

                _buildActionButton(
                  context,
                  icon: Icons.share_outlined,
                  label: '${post.sharesCount}',
                  onTap: () {},
                ),

                _buildActionButton(
                  context,
                  icon: post.isSaved
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  label: '',
                  color: post.isSaved
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                  onTap: () {
                    ref.read(feedProvider.notifier).toggleSave(post.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Action button
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color ?? AppColors.textSecondary, size: 20),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  /// Confirm delete dialog
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(feedProvider.notifier).deletePost(post.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) =>
          const Center(child: Text('Comments feature coming soon')),
    );
  }
}
