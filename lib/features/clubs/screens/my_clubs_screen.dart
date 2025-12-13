import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../events/screens/clubs_screen.dart';
import '../../events/providers/clubs_provider.dart';
import '../../events/models/club_model.dart';

import '../../../core/theme/app_colors.dart';

class MyClubsScreen extends ConsumerWidget {
  const MyClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myClubsAsync = ref.watch(myClubsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Clubs'),
      ),
      body: myClubsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (clubs) {
          if (clubs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  const Text('You have not joined any clubs yet'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: clubs.length,
            itemBuilder: (_, i) => ClubCard(club: clubs[i]),
          );
        },
      ),
    );
  }
}
