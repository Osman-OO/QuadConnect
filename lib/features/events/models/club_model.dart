import 'package:cloud_firestore/cloud_firestore.dart';

/// A campus club or organization
class ClubModel {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? coverImageUrl;
  final String category;
  final List<String> adminIds;
  final int membersCount;
  final bool isVerified;
  final String? website;
  final String? instagram;
  final String? email;
  final String meetingSchedule;
  final String? meetingLocation;
  final DateTime createdAt;

  const ClubModel({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.coverImageUrl,
    required this.category,
    this.adminIds = const [],
    this.membersCount = 0,
    this.isVerified = false,
    this.website,
    this.instagram,
    this.email,
    this.meetingSchedule = '',
    this.meetingLocation,
    required this.createdAt,
  });

  factory ClubModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logoUrl: data['logoUrl'],
      coverImageUrl: data['coverImageUrl'],
      category: data['category'] ?? 'General',
      adminIds: List<String>.from(data['adminIds'] ?? []),
      membersCount: data['membersCount'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      website: data['website'],
      instagram: data['instagram'],
      email: data['email'],
      meetingSchedule: data['meetingSchedule'] ?? '',
      meetingLocation: data['meetingLocation'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'category': category,
      'adminIds': adminIds,
      'membersCount': membersCount,
      'isVerified': isVerified,
      'website': website,
      'instagram': instagram,
      'email': email,
      'meetingSchedule': meetingSchedule,
      'meetingLocation': meetingLocation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? coverImageUrl,
    String? category,
    List<String>? adminIds,
    int? membersCount,
    bool? isVerified,
    String? website,
    String? instagram,
    String? email,
    String? meetingSchedule,
    String? meetingLocation,
    DateTime? createdAt,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      category: category ?? this.category,
      adminIds: adminIds ?? this.adminIds,
      membersCount: membersCount ?? this.membersCount,
      isVerified: isVerified ?? this.isVerified,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
      email: email ?? this.email,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool isAdmin(String userId) => adminIds.contains(userId);
}

