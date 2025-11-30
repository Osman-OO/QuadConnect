import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/quad_avatar.dart';
import '../../../core/widgets/quad_card.dart';
import '../../auth/providers/auth_provider.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

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
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh feed
        },
        child: CustomScrollView(
          slivers: [
            // Create post prompt
            SliverToBoxAdapter(
              child: _buildCreatePostCard(context, authState),
            ),

            // Posts list - placeholder for now
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPostCard(context, index),
                childCount: 5, // Placeholder posts
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new post
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCreatePostCard(BuildContext context, AuthState authState) {
    return QuadCard(
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.image_outlined, color: AppColors.success),
            onPressed: () {
              // TODO: Add image
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, int index) {
    // Placeholder post for demo
    final posts = [
      {
        'author': 'Sarah Chen',
        'initials': 'SC',
        'time': '2 hours ago',
        'content':
            'Just finished the Computer Science midterm! 🎉 Who else is relieved? Time for coffee at the library cafe ☕',
        'likes': 42,
        'comments': 8,
      },
      {
        'author': 'Marcus Johnson',
        'initials': 'MJ',
        'time': '4 hours ago',
        'content':
            'Anyone want to form a study group for Organic Chemistry? Meeting at the Quad tomorrow at 3pm. Bring snacks! 📚',
        'likes': 28,
        'comments': 15,
      },
      {
        'author': 'Photography Club',
        'initials': 'PC',
        'time': '6 hours ago',
        'content':
            'Sunset photowalk this Friday! 🌅 Meet at the main fountain at 5pm. All skill levels welcome. Bring your cameras or just your phone!',
        'likes': 89,
        'comments': 12,
      },
      {
        'author': 'Emily Rodriguez',
        'initials': 'ER',
        'time': '1 day ago',
        'content':
            'Lost my blue water bottle somewhere between the gym and the engineering building. If anyone finds it, please let me know! 💙',
        'likes': 5,
        'comments': 3,
      },
      {
        'author': 'Student Government',
        'initials': 'SG',
        'time': '1 day ago',
        'content':
            '🗳️ VOTING IS OPEN! Cast your vote for next year\'s student body president. Polls close Friday at midnight. Your voice matters!',
        'likes': 156,
        'comments': 24,
      },
    ];

    final post = posts[index % posts.length];

    return QuadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              QuadAvatar(initials: post['initials'] as String, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['author'] as String,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      post['time'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(post['content'] as String),

          const SizedBox(height: 16),

          // Actions row
          Row(
            children: [
              _buildActionButton(
                context,
                Icons.favorite_border,
                '${post['likes']}',
                AppColors.error,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                context,
                Icons.chat_bubble_outline,
                '${post['comments']}',
                AppColors.primary,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                context,
                Icons.share_outlined,
                'Share',
                AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

