import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/quad_card.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../providers/events_provider.dart';
import '../models/event_model.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventsProvider);
    final categories = ref.watch(eventCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendar view coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips - horizontal scroll
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length + 1, // +1 for "All" option
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryChip(
                    ref,
                    'All',
                    Icons.apps,
                    eventsState.selectedCategory == null,
                    () => ref.read(eventsProvider.notifier).setCategory(null),
                  );
                }
                final cat = categories[index - 1];
                return _buildCategoryChip(
                  ref,
                  cat['name'] as String,
                  cat['icon'] as IconData,
                  eventsState.selectedCategory == cat['name'],
                  () => ref
                      .read(eventsProvider.notifier)
                      .setCategory(cat['name'] as String),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Events list with loading/error/empty states
          Expanded(
            child: eventsState.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: 5,
                    itemBuilder: (context, index) => const EventCardSkeleton(),
                  )
                : eventsState.error != null
                ? Center(child: Text('Error: ${eventsState.error}'))
                : eventsState.filteredEvents.isEmpty
                ? _buildEmptyState(context)
                : RefreshIndicator(
                    onRefresh: () async =>
                        await Future.delayed(const Duration(milliseconds: 500)),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: eventsState.filteredEvents.length,
                      itemBuilder: (context, index) => _buildEventCard(
                        context,
                        ref,
                        eventsState.filteredEvents[index],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different category or create one!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    WidgetRef ref,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Filter Events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('This Week'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('This Month'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Most Popular'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateEventSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    String selectedCategory = 'Social';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Event',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            [
                                  'Academic',
                                  'Social',
                                  'Sports',
                                  'Career',
                                  'Arts',
                                  'Clubs',
                                ]
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => selectedCategory = v!),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('Date & Time'),
                        subtitle: Text(
                          DateFormat(
                            'MMM d, yyyy - h:mm a',
                          ).format(selectedDate),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null && context.mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );
                            if (time != null) {
                              setState(
                                () => selectedDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      locationController.text.isNotEmpty) {
                    // Convert string category to enum
                    final catEnum = EventCategory.values.firstWhere(
                      (e) =>
                          e.name.toLowerCase() ==
                          selectedCategory.toLowerCase(),
                      orElse: () => EventCategory.other,
                    );
                    await ref
                        .read(eventsProvider.notifier)
                        .createEvent(
                          title: titleController.text,
                          description: descController.text,
                          location: locationController.text,
                          category: catEnum,
                          startTime: selectedDate,
                          endTime: selectedDate.add(const Duration(hours: 2)),
                        );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Event'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color for event category
  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.academic:
        return AppColors.primary;
      case EventCategory.social:
        return AppColors.secondary;
      case EventCategory.sports:
        return AppColors.accent;
      case EventCategory.arts:
        return AppColors.success;
      case EventCategory.career:
        return AppColors.warning;
      case EventCategory.workshop:
        return AppColors.primary;
      case EventCategory.club:
        return AppColors.primaryLight;
      case EventCategory.other:
        return AppColors.textSecondary;
    }
  }

  Widget _buildEventCard(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
  ) {
    final color = _getCategoryColor(event.category);
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');

    return QuadCard(
      onTap: () => _showEventDetails(context, ref, event),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  event.startTime.day.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateFormat.format(event.startTime).split(' ')[0],
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.category.name[0].toUpperCase() +
                            event.category.name.substring(1),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeFormat.format(event.startTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.maxAttendees > 0
                          ? '${event.attendeesCount}/${event.maxAttendees} going'
                          : '${event.attendeesCount} going',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: event.isFull
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (event.isFull) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FULL',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    _RsvpButton(eventId: event.id, isFull: event.isFull),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              event.description.isEmpty ? 'No description' : event.description,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                DateFormat('EEEE, MMMM d, yyyy').format(event.startTime),
              ),
              subtitle: Text(
                '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(event.location),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Organized by ${event.organizerName}'),
              contentPadding: EdgeInsets.zero,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: _RsvpButton(eventId: event.id, expanded: true),
            ),
          ],
        ),
      ),
    );
  }
}

/// RSVP Button with real-time status and capacity awareness
class _RsvpButton extends ConsumerWidget {
  final String eventId;
  final bool expanded;
  final bool isFull;

  const _RsvpButton({
    required this.eventId,
    this.expanded = false,
    this.isFull = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rsvpStatus = ref.watch(eventRsvpStatusProvider(eventId));
    final isRsvped = rsvpStatus.maybeWhen(data: (v) => v, orElse: () => false);

    // Handle RSVP with feedback
    Future<void> handleRsvp() async {
      final success = await ref
          .read(eventsProvider.notifier)
          .toggleRsvp(eventId);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sorry, this event is at capacity!'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    if (expanded) {
      return ElevatedButton.icon(
        onPressed: (isFull && !isRsvped) ? null : handleRsvp,
        icon: Icon(isRsvped ? Icons.check : (isFull ? Icons.block : Icons.add)),
        label: Text(isRsvped ? 'Going!' : (isFull ? 'Full' : 'RSVP')),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRsvped ? AppColors.success : null,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    return TextButton(
      onPressed: (isFull && !isRsvped) ? null : handleRsvp,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 32),
        foregroundColor: isRsvped
            ? AppColors.success
            : (isFull ? AppColors.textTertiary : null),
      ),
      child: Text(isRsvped ? '✓ Going' : (isFull ? 'Full' : 'RSVP')),
    );
  }
}
