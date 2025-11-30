import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/quad_card.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filter events
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO: Calendar view
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Category chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All', true),
                  _buildCategoryChip('Academic', false),
                  _buildCategoryChip('Social', false),
                  _buildCategoryChip('Sports', false),
                  _buildCategoryChip('Career', false),
                  _buildCategoryChip('Clubs', false),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Events list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: 6, // Placeholder events
                itemBuilder: (context, index) =>
                    _buildEventCard(context, index),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Create new event
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Filter by category
        },
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, int index) {
    // Placeholder events for demo
    final events = [
      {
        'title': 'Tech Career Fair 2024',
        'date': 'Dec 5, 2024',
        'time': '10:00 AM - 4:00 PM',
        'location': 'Student Union Ballroom',
        'category': 'Career',
        'attendees': 234,
        'color': AppColors.accent,
      },
      {
        'title': 'Study Night: Finals Week',
        'date': 'Dec 8, 2024',
        'time': '6:00 PM - 2:00 AM',
        'location': 'Main Library',
        'category': 'Academic',
        'attendees': 89,
        'color': AppColors.primary,
      },
      {
        'title': 'Basketball: Home Game vs State',
        'date': 'Dec 10, 2024',
        'time': '7:00 PM',
        'location': 'University Arena',
        'category': 'Sports',
        'attendees': 1250,
        'color': AppColors.secondary,
      },
      {
        'title': 'Winter Concert',
        'date': 'Dec 12, 2024',
        'time': '8:00 PM',
        'location': 'Performing Arts Center',
        'category': 'Arts',
        'attendees': 456,
        'color': AppColors.success,
      },
      {
        'title': 'Coding Club Hackathon',
        'date': 'Dec 15-16, 2024',
        'time': '48 Hours',
        'location': 'Engineering Building',
        'category': 'Academic',
        'attendees': 120,
        'color': AppColors.primary,
      },
      {
        'title': 'End of Semester Party',
        'date': 'Dec 20, 2024',
        'time': '9:00 PM',
        'location': 'Campus Green',
        'category': 'Social',
        'attendees': 678,
        'color': AppColors.secondary,
      },
    ];

    final event = events[index % events.length];

    return QuadCard(
      onTap: () {
        // TODO: Navigate to event details
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: (event['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  (event['date'] as String).split(' ')[1].replaceAll(',', ''),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: event['color'] as Color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  (event['date'] as String).split(' ')[0],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: event['color'] as Color,
                  ),
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
                        color: (event['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event['category'] as String,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: event['color'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event['title'] as String,
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
                      event['time'] as String,
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
                        event['location'] as String,
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
                      '${event['attendees']} going',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('RSVP'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
