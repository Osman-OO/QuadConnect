import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/event_model.dart';

/// State for events list
class EventsState {
  final List<EventModel> events;
  final String? selectedCategory; // null means "all"
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

  /// Filter events by selected category
  List<EventModel> get filteredEvents {
    if (selectedCategory == null) return events;
    return events
        .where(
          (e) =>
              e.category.name.toLowerCase() == selectedCategory!.toLowerCase(),
        )
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
    _firestoreService.streamUpcomingEvents().listen(
      (snapshot) {
        final events = snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList();
        state = state.copyWith(events: events, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  /// Change category filter (null = all)
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
  Future<void> toggleRsvp(String eventId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final userId = authState.user!.uid;
    // Check current status and toggle
    final doc = await _firestoreService.events
        .doc(eventId)
        .collection('attendees')
        .doc(userId)
        .get();
    await _firestoreService.rsvpEvent(eventId, userId, doc.exists);
  }
}

/// Provider for events
final eventsProvider = NotifierProvider<EventsNotifier, EventsState>(() {
  return EventsNotifier();
});

/// Stream provider for RSVP status
final eventRsvpStatusProvider = StreamProvider.family<bool, String>((
  ref,
  eventId,
) {
  final authState = ref.watch(authNotifierProvider);
  if (authState.user == null) return Stream.value(false);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamRsvpStatus(eventId, authState.user!.uid);
});

/// Available event categories for filtering
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
