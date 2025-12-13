import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/club_model.dart';

/// ---------------------------
/// State for Clubs
/// ---------------------------
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
      result = result
          .where((c) => c.category.toLowerCase() == selectedCategory!.toLowerCase())
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.description.toLowerCase().contains(query))
          .toList();
    }
    return result;
  }
}

/// ---------------------------
/// Clubs Notifier
/// ---------------------------
class ClubsNotifier extends Notifier<ClubsState> {
  late final FirestoreService _firestoreService;

  @override
  ClubsState build() {
    _firestoreService = ref.watch(firestoreServiceProvider);
    _subscribeToClubs();
    return const ClubsState(isLoading: true);
  }

  /// Subscribe to all clubs
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

  /// Add a club locally (for demo/sample)
  void addLocalClub(ClubModel club) {
    state = state.copyWith(clubs: [...state.clubs, club]);
  }

  /// Set category filter
  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Toggle membership (join/leave)
  Future<void> toggleMembership(String clubId) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) return;

    final userId = authState.user!.uid;
    final memberRef = _firestoreService.clubs.doc(clubId).collection('members').doc(userId);
    final doc = await memberRef.get();

    if (doc.exists) {
      // Leave club
      await memberRef.delete();
      await _firestoreService.clubs.doc(clubId).update({'membersCount': FieldValue.increment(-1)});
    } else {
      // Join club
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

      // Add current user as member
      await docRef.collection('members').doc(userId).set({'joinedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      state = state.copyWith(error: 'Failed to create club: $e');
    }
  }

  /// Delete a club
  Future<void> deleteClub(String clubId) async {
    try {
      await _firestoreService.clubs.doc(clubId).delete();
      state = state.copyWith(clubs: state.clubs.where((c) => c.id != clubId).toList());
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete club: $e');
    }
  }
}

/// ---------------------------
/// Providers
/// ---------------------------
final clubsProvider = NotifierProvider<ClubsNotifier, ClubsState>(() => ClubsNotifier());

/// Stream provider for membership status (joined/not joined)
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

/// ---------------------------
/// Stream provider for My Clubs (user-joined clubs)
/// ---------------------------
final myClubsProvider = StreamProvider<List<ClubModel>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState.user == null) return const Stream.empty();

  final userId = authState.user!.uid;
  final firestore = ref.watch(firestoreServiceProvider);

  return firestore.clubs.snapshots().asyncMap((snapshot) async {
    final List<ClubModel> joined = [];

    for (final doc in snapshot.docs) {
      final memberDoc =
          await doc.reference.collection('members').doc(userId).get();
      if (memberDoc.exists) {
        joined.add(ClubModel.fromFirestore(doc));
      }
    }

    return joined;
  });
});
