import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/quad_avatar.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {
              // TODO: New message
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: 8, // Placeholder conversations
        itemBuilder: (context, index) => _buildConversationTile(context, index),
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, int index) {
    // Placeholder conversations
    final conversations = [
      {
        'name': 'Study Group - CS101',
        'initials': 'SG',
        'message': 'Alex: Does anyone have the notes from last lecture?',
        'time': '2m',
        'unread': 3,
        'isGroup': true,
      },
      {
        'name': 'Jessica Wong',
        'initials': 'JW',
        'message': 'Sure, I can meet at the library at 4pm',
        'time': '15m',
        'unread': 1,
        'isGroup': false,
      },
      {
        'name': 'Photography Club',
        'initials': 'PC',
        'message': 'Next meeting moved to Thursday!',
        'time': '1h',
        'unread': 0,
        'isGroup': true,
      },
      {
        'name': 'Marcus Johnson',
        'initials': 'MJ',
        'message': 'Thanks for the help with the project!',
        'time': '3h',
        'unread': 0,
        'isGroup': false,
      },
      {
        'name': 'Roommates',
        'initials': 'RM',
        'message': 'You: I\'ll pick up groceries on the way',
        'time': '5h',
        'unread': 0,
        'isGroup': true,
      },
      {
        'name': 'Professor Smith',
        'initials': 'PS',
        'message': 'Office hours are from 2-4pm today',
        'time': '1d',
        'unread': 0,
        'isGroup': false,
      },
      {
        'name': 'Intramural Soccer',
        'initials': 'IS',
        'message': 'Game tomorrow at 6pm, be there!',
        'time': '1d',
        'unread': 0,
        'isGroup': true,
      },
      {
        'name': 'Sarah Chen',
        'initials': 'SC',
        'message': 'You: See you at the party!',
        'time': '2d',
        'unread': 0,
        'isGroup': false,
      },
    ];

    final convo = conversations[index % conversations.length];
    final hasUnread = (convo['unread'] as int) > 0;

    return ListTile(
      leading: Stack(
        children: [
          QuadAvatar(initials: convo['initials'] as String, size: 52),
          if (convo['isGroup'] as bool)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.group, size: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        convo['name'] as String,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        convo['message'] as String,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            convo['time'] as String,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: hasUnread ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${convo['unread']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        // TODO: Open conversation
      },
    );
  }
}
