/// App-wide constants for QuadConnect
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'QuadConnect';
  static const String appTagline = 'Your Campus, Connected';

  // Pagination
  static const int feedPageSize = 20;
  static const int commentsPageSize = 15;
  static const int eventsPageSize = 10;
  static const int usersPageSize = 25;

  // Image settings
  static const int maxImageWidth = 1080;
  static const int maxImageHeight = 1920;
  static const int thumbnailSize = 200;
  static const int avatarSize = 150;
  static const double maxImageSizeMB = 5.0;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 1);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxBioLength = 160;
  static const int maxPostLength = 500;
  static const int maxCommentLength = 300;
  static const int maxEventDescLength = 1000;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Firestore collection names
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String posts = 'posts';
  static const String comments = 'comments';
  static const String likes = 'likes';
  static const String events = 'events';
  static const String clubs = 'clubs';
  static const String messages = 'messages';
  static const String conversations = 'conversations';
  static const String notifications = 'notifications';
  static const String followers = 'followers';
  static const String following = 'following';
}

/// Storage paths
class StoragePaths {
  StoragePaths._();

  static const String avatars = 'avatars';
  static const String posts = 'posts';
  static const String events = 'events';
  static const String clubs = 'clubs';
}

