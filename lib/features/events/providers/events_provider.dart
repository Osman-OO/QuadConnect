import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/event_model.dart';

/// State for events list
class EventsState {
  final List<EventModel> events;
  final String? selectedCategory; // null = all
  final bool isLoading;
  final String? error;

  const EventsState({
    this.events = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
  });

  EventsState copyWith({
    List<EventModel>? events,
    String? selectedCategory,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
  }) {
    return EventsState(
      events: events ?? this.events,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Filter events by category
  List<EventModel> get filteredEvents {
    if (selectedCategory == null) return events;
    return events
        .where((e) =>
            e.category.name.toLowerCase() == selectedCategory!.toLowerCase())
        .toList();
  }
}

/// Manages events and RSVP
class EventsNotifier extends Notifier<EventsState> {
  late FirestoreService _firestoreService;

  @override
  EventsState build() {
    _firestoreService = ref.watch(firestoreServiceProvider);
    _subscribeToEvents();
    return const EventsState(isLoading: true);
  }

  void _subscribeToEvents() {
  final selectedCategory = state.selectedCategory;

  _firestoreService.streamUpcomingEvents(category: selectedCategory).listen(
    (events) {
      final now = DateTime.now();
      final upcomingEvents = events
          .where((e) => e.startTime.isAfter(now))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      state = state.copyWith(events: upcomingEvents, isLoading: false);
    },
    onError: (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    },
  );
}


  /// Set category filter
  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  /// Create a new event
  Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    EventCategory category = EventCategory.other,
    String? imageUrl,
    int maxAttendees = 0,
    bool isRsvpRequired = false,
    List<String> tags = const [],
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final user = authState.user!;
    try {
      await _firestoreService.createEvent({
        'title': title,
        'description': description,
        'location': location,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'category': category.name,
        'imageUrl': imageUrl,
        'organizerId': user.uid,
        'organizerName': user.displayName,
        'attendeesCount': 0,
        'maxAttendees': maxAttendees,
        'isRsvpRequired': isRsvpRequired,
        'tags': tags,
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to create event: $e');
    }
  }

  /// Toggle RSVP for an event
  Future<bool> toggleRsvp(String eventId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return false;

    final userId = authState.user!.uid;

    // Check current RSVP status
    final rsvpSnapshot = await _firestoreService.events
        .doc(eventId)
        .collection('rsvps')
        .doc(userId)
        .get();

    final isAttending = rsvpSnapshot.exists;

    // Toggle RSVP
    await _firestoreService.rsvpEvent(eventId, userId, !isAttending);

    return !isAttending;
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    try {
      final eventDoc = await _firestoreService.events.doc(eventId).get();
      final eventData = eventDoc.data() as Map<String, dynamic>?;

      if (eventData != null &&
          eventData['organizerId'] == authState.user!.uid) {
        await _firestoreService.events.doc(eventId).delete();
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete event: $e');
    }
  }

  /// Update an event
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.events.doc(eventId).update(updates);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update event: $e');
    }
  }
}

/// Provider for events
final eventsProvider = NotifierProvider<EventsNotifier, EventsState>(() {
  return EventsNotifier();
});

/// Stream provider for RSVP status
final eventRsvpStatusProvider = StreamProvider.family<bool, String>(
  (ref, eventId) {
    final authState = ref.watch(authNotifierProvider);
    if (authState.user == null) return Stream.value(false);

    final firestoreService = ref.watch(firestoreServiceProvider);
    return firestoreService.streamRsvpStatus(eventId, authState.user!.uid);
  },
);

/// Event categories for filtering
final eventCategoriesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'name': 'Academic', 'icon': Icons.school},
    {'name': 'Social', 'icon': Icons.celebration},
    {'name': 'Sports', 'icon': Icons.sports_basketball},
    {'name': 'Arts', 'icon': Icons.palette},
    {'name': 'Career', 'icon': Icons.work},
    {'name': 'Clubs', 'icon': Icons.groups},
  ];
});
