import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostTile extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const PostTile({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(post.content),
      subtitle: Text('by ${post.authorName}'),
      leading: post.imageUrls.isNotEmpty
          ? Image.network(
              post.imageUrls.first,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
          : null,
      trailing: post.isSaved ? const Icon(Icons.bookmark) : null,
    );
  }
}
