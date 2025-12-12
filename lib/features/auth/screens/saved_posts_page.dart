import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feed/providers/feed_provider.dart';
import '../../feed/models/post_model.dart';
import '../profile/profile_page.dart';

class SavedPostsPage extends ConsumerWidget {
  const SavedPostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    final savedPosts = feedState.savedPosts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Go to Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          )
        ],
      ),
      body: savedPosts.isEmpty
          ? const Center(
              child: Text(
                'You have no saved posts.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                final post = savedPosts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(post.authorName),
                    subtitle: Text(post.content),
                    trailing: Icon(
                      post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: post.isSaved ? Colors.blue : null,
                    ),
                    onTap: () {
                      // Optional: show post details
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(post.authorName),
                          content: Text(post.content),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

