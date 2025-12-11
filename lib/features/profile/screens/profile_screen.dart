import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/quad_avatar.dart';
import '../../../core/widgets/quad_button.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile header
            _buildProfileHeader(context, user),

            const SizedBox(height: 32),

            // Stats row
            _buildStatsRow(context, user),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: QuadButton(
                      label: 'Edit Profile',
                      variant: QuadButtonVariant.outline,
                      height: 44,
                      onPressed: () {
                        // TODO: Edit profile
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuadButton(
                      label: 'Share Profile',
                      variant: QuadButtonVariant.outline,
                      height: 44,
                      onPressed: () {
                        // TODO: Share profile
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Menu options
            _buildMenuSection(context, ref),

            const SizedBox(height: 24),

            // Sign out button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuadButton(
                label: 'Sign Out',
                variant: QuadButtonVariant.danger,
                icon: Icons.logout,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Column(
      children: [
        ProfileAvatar(
          imageUrl: user?.photoUrl,
          initials: user?.initials ?? '?',
          isEditable: true,
          onTap: () {
            // TODO: Change photo
          },
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? 'Student',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        if (user?.major != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              user!.major!,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
        if (user?.bio != null && user!.bio!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(context, '${user?.postsCount ?? 0}', 'Posts'),
        _buildDivider(),
        _buildStatItem(context, '${user?.followersCount ?? 0}', 'Followers'),
        _buildDivider(),
        _buildStatItem(context, '${user?.followingCount ?? 0}', 'Following'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to list
      },
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: AppColors.border);
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          Icons.bookmark_outline,
          'Saved Posts',
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          Icons.event_outlined,
          'My Events',
          onTap: () {},
        ),
        _buildMenuItem(context, Icons.group_outlined, 'My Clubs', onTap: () {}),
        _buildMenuItem(
          context,
          Icons.history,
          'Activity History',
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          Icons.help_outline,
          'Help & Support',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
