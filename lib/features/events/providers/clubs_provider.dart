import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

import '../models/club_model.dart';

/// State for clubs list
class ClubsState {
  final List<ClubModel> clubs;
  final String? selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const ClubsState({
    this.clubs = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  ClubsState copyWith({
    List<ClubModel>? clubs,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
  }) {
    return ClubsState(
      clubs: clubs ?? this.clubs,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Filter clubs by category and search query
  List<ClubModel> get filteredClubs {
    var result = clubs;
    if (selectedCategory != null) {
      result = result.where((c) => c.category.toLowerCase() == selectedCategory!.toLowerCase()).toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((c) =>
        c.name.toLowerCase().contains(query) ||
        c.description.toLowerCase().contains(query)
      ).toList();
    }
    return result;
  }
}

/// Manages clubs
class ClubsNotifier extends Notifier<ClubsState> {
  late FirestoreService _firestoreService;

  @override
  ClubsState build() {
    _firestoreService = ref.watch(firestoreServiceProvider);
    _subscribeToClubs();
    return const ClubsState(isLoading: true);
  }

  void _subscribeToClubs() {
    _firestoreService.clubs
        .orderBy('membersCount', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final clubs = snapshot.docs.map((doc) => ClubModel.fromFirestore(doc)).toList();
        state = state.copyWith(clubs: clubs, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Join or leave a club
  Future<void> toggleMembership(String clubId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final userId = authState.user!.uid;
    final memberRef = _firestoreService.clubs.doc(clubId).collection('members').doc(userId);
    final doc = await memberRef.get();

    if (doc.exists) {
      await memberRef.delete();
      await _firestoreService.clubs.doc(clubId).update({'membersCount': FieldValue.increment(-1)});
    } else {
      await memberRef.set({'joinedAt': FieldValue.serverTimestamp()});
      await _firestoreService.clubs.doc(clubId).update({'membersCount': FieldValue.increment(1)});
    }
  }

  /// Create a new club
  Future<void> createClub({
    required String name,
    required String description,
    required String category,
    String? logoUrl,
    String meetingSchedule = '',
    String? meetingLocation,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final userId = authState.user!.uid;
    try {
      final docRef = await _firestoreService.clubs.add({
        'name': name,
        'description': description,
        'category': category,
        'logoUrl': logoUrl,
        'adminIds': [userId],
        'membersCount': 1,
        'isVerified': false,
        'meetingSchedule': meetingSchedule,
        'meetingLocation': meetingLocation,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Creator automatically joins
      await docRef.collection('members').doc(userId).set({'joinedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      state = state.copyWith(error: 'Failed to create club: $e');
    }
  }
}

/// Provider for clubs
final clubsProvider = NotifierProvider<ClubsNotifier, ClubsState>(() => ClubsNotifier());

/// Stream provider for membership status
final clubMembershipProvider = StreamProvider.family<bool, String>((ref, clubId) {
  final authState = ref.watch(authNotifierProvider);
  if (authState.user == null) return Stream.value(false);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.clubs
      .doc(clubId)
      .collection('members')
      .doc(authState.user!.uid)
      .snapshots()
      .map((doc) => doc.exists);
});

