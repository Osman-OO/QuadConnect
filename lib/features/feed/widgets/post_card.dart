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
    // Watch the like status
    final likeStatus = ref.watch(postLikeStatusProvider(post.id));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
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
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  post.authorName,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Post content
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),

            // Post images
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
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
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

            // Stats & actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Likes
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

                // Comments
                _buildActionButton(
                  context,
                  icon: Icons.comment_outlined,
                  label: '${post.commentsCount}',
                  onTap: () {
                    _showComments(context, ref);
                  },
                ),

                // Shares
                _buildActionButton(
                  context,
                  icon: Icons.share_outlined,
                  label: '${post.sharesCount}',
                  onTap: () {
                    // TODO: Implement share logic
                  },
                ),

                // Save
                _buildActionButton(
                  context,
                  icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: '',
                  color: post.isSaved ? AppColors.secondary : AppColors.textSecondary,
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

  void _showComments(BuildContext context, WidgetRef ref) {
    // TODO: Implement showing comments in bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (_) => const Center(child: Text('Comments feature coming soon')),
    );
  }
}
