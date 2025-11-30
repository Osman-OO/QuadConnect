import 'package:cloud_firestore/cloud_firestore.dart';

/// Event categories
enum EventCategory {
  academic,
  social,
  sports,
  arts,
  career,
  workshop,
  club,
  other,
}

/// A campus event
class EventModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String organizerId;
  final String organizerName;
  final String? clubId;
  final String? clubName;
  final EventCategory category;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final int attendeesCount;
  final int maxAttendees;
  final bool isRsvpRequired;
  final List<String> tags;
  final DateTime createdAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.organizerId,
    required this.organizerName,
    this.clubId,
    this.clubName,
    this.category = EventCategory.other,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.attendeesCount = 0,
    this.maxAttendees = 0, // 0 means unlimited
    this.isRsvpRequired = false,
    this.tags = const [],
    required this.createdAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      clubId: data['clubId'],
      clubName: data['clubName'],
      category: EventCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => EventCategory.other,
      ),
      location: data['location'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attendeesCount: data['attendeesCount'] ?? 0,
      maxAttendees: data['maxAttendees'] ?? 0,
      isRsvpRequired: data['isRsvpRequired'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'clubId': clubId,
      'clubName': clubName,
      'category': category.name,
      'location': location,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'attendeesCount': attendeesCount,
      'maxAttendees': maxAttendees,
      'isRsvpRequired': isRsvpRequired,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? organizerId,
    String? organizerName,
    String? clubId,
    String? clubName,
    EventCategory? category,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    int? attendeesCount,
    int? maxAttendees,
    bool? isRsvpRequired,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      category: category ?? this.category,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      isRsvpRequired: isRsvpRequired ?? this.isRsvpRequired,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isFull => maxAttendees > 0 && attendeesCount >= maxAttendees;
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isPast => endTime.isBefore(DateTime.now());
}

