import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a QuadConnect user (student)
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String? major;
  final String? graduationYear;
  final String? university;
  final List<String> interests;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastActive;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.major,
    this.graduationYear,
    this.university,
    this.interests = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isVerified = false,
    required this.createdAt,
    this.lastActive,
  });

  /// Create an empty user (for loading states)
  factory UserModel.empty() => UserModel(
        uid: '',
        email: '',
        displayName: '',
        createdAt: DateTime.now(),
      );

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      major: data['major'],
      graduationYear: data['graduationYear'],
      university: data['university'],
      interests: List<String>.from(data['interests'] ?? []),
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'major': major,
      'graduationYear': graduationYear,
      'university': university,
      'interests': interests,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  /// Copy with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    String? major,
    String? graduationYear,
    String? university,
    List<String>? interests,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      university: university ?? this.university,
      interests: interests ?? this.interests,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;

  /// Get initials for avatar fallback
  String get initials {
    if (displayName.isEmpty) return '?';
    final names = displayName.trim().split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
  }
}

