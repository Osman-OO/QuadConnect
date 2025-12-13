import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/quad_card.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../providers/clubs_provider.dart';
import '../models/club_model.dart';

class ClubsScreen extends ConsumerStatefulWidget {
  const ClubsScreen({super.key});

  @override
  ConsumerState<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends ConsumerState<ClubsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _populateSampleClubs();
    });
  }

  void _populateSampleClubs() {
    final currentClubs = ref.read(clubsProvider).filteredClubs;
    if (currentClubs.isEmpty) {
      final sampleClubs = [
        ClubModel(
          id: '1',
          name: 'Math Club',
          category: 'Academic',
          description: 'For students who love math.',
          membersCount: 12,
          createdAt: DateTime.now(),
        ),
        ClubModel(
          id: '2',
          name: 'Soccer Club',
          category: 'Sports',
          description: 'Join for weekly matches and tournaments.',
          membersCount: 20,
          createdAt: DateTime.now(),
        ),
        ClubModel(
          id: '3',
          name: 'Art Club',
          category: 'Arts',
          description: 'Express your creativity with peers.',
          membersCount: 15,
          createdAt: DateTime.now(),
        ),
        ClubModel(
          id: '4',
          name: 'Debate Club',
          category: 'Academic',
          description: 'Sharpen your public speaking skills.',
          membersCount: 10,
          createdAt: DateTime.now(),
        ),
        ClubModel(
          id: '5',
          name: 'Music Club',
          category: 'Arts',
          description: 'For students who love music.',
          membersCount: 18,
          createdAt: DateTime.now(),
        ),
      ];

      final notifier = ref.read(clubsProvider.notifier);
      for (var club in sampleClubs) {
        notifier.addLocalClub(club);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubsState = ref.watch(clubsProvider);
    final categories = ['All', 'Academic', 'Sports', 'Arts', 'Social', 'Professional', 'Cultural'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Clubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCreateClubSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clubs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(clubsProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                ref.read(clubsProvider.notifier).setSearchQuery(value);
              },
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected =
                    (cat == 'All' && clubsState.selectedCategory == null) ||
                        clubsState.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(clubsProvider.notifier).setCategory(cat == 'All' ? null : cat);
                    },
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: clubsState.isLoading
                ? _buildSkeletonGrid()
                : clubsState.filteredClubs.isEmpty
                    ? _buildEmptyState()
                    : _buildClubsGrid(clubsState.filteredClubs),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerEffect(
        child: SkeletonBox(height: 150, borderRadius: 12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('No clubs found', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Try a different search or create one!', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildClubsGrid(List<ClubModel> clubs) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: clubs.length,
      itemBuilder: (context, index) => ClubCard(club: clubs[index]),
    );
  }

  void _showCreateClubSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Academic';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Create Club', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Club Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: ['Academic','Sports','Arts','Social','Professional','Cultural'].map(
                          (c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))),
                        ).toList(),
                        onChanged: (v) => setState(() => selectedCategory = v!),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    await ref.read(clubsProvider.notifier).createClub(
                      name: nameController.text,
                      description: descController.text,
                      category: selectedCategory,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('Create Club', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------
// Top-level ClubCard
// ---------------------
class ClubCard extends ConsumerWidget {
  final ClubModel club;
  const ClubCard({required this.club, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipStatus = ref.watch(clubMembershipProvider(club.id));
    final isMember = membershipStatus.maybeWhen(data: (v) => v, orElse: () => false);

    return QuadCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: club.logoUrl != null
                            ? ClipOval(child: Image.network(club.logoUrl!, fit: BoxFit.cover))
                            : Center(
                                child: Text(
                                  club.name[0].toUpperCase(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      club.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      club.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    ref.read(clubsProvider.notifier).deleteClub(club.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text('Delete Club')),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                ref.read(clubsProvider.notifier).toggleMembership(club.id);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                backgroundColor: isMember ? AppColors.primaryLight : AppColors.surfaceVariant,
              ),
              child: Text(
                isMember ? 'Joined' : 'Join',
                style: TextStyle(
                  color: isMember ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
