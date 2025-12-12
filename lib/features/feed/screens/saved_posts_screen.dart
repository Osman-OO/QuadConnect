import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/post_model.dart';
import '../widgets/post_tile.dart';

class SavedPostsScreen extends ConsumerWidget {
  final List<PostModel> savedPosts;

  const SavedPostsScreen({super.key, required this.savedPosts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: savedPosts.isEmpty
          ? const Center(child: Text('No saved posts yet.'))
          : ListView.builder(
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                final post = savedPosts[index];
                return PostTile(
                  post: post,
                  onTap: () {
                    // Navigate to author's profile
                    context.push('/profile/${post.authorId}');
                  },
                );
              },
            ),
    );
  }
}
