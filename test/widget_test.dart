// QuadConnect Tests
// Unit tests for models and business logic

import 'package:flutter_test/flutter_test.dart';
import 'package:quadcnct/features/feed/models/post_model.dart';
import 'package:quadcnct/features/events/models/event_model.dart';
import 'package:quadcnct/features/events/models/club_model.dart';

void main() {
  group('PostModel Tests', () {
    test('creates post with required fields', () {
      final post = PostModel(
        id: 'test-id',
        authorId: 'author-1',
        authorName: 'Test User',
        content: 'Hello World',
        createdAt: DateTime.now(),
      );

      expect(post.id, 'test-id');
      expect(post.authorName, 'Test User');
      expect(post.content, 'Hello World');
      expect(post.likesCount, 0);
      expect(post.commentsCount, 0);
      expect(post.type, PostType.text);
    });

    test('hasImages returns true when imageUrls is not empty', () {
      final postWithImages = PostModel(
        id: 'test-id',
        authorId: 'author-1',
        authorName: 'Test User',
        content: 'Check this out!',
        imageUrls: ['https://example.com/image.jpg'],
        createdAt: DateTime.now(),
      );

      final postWithoutImages = PostModel(
        id: 'test-id-2',
        authorId: 'author-1',
        authorName: 'Test User',
        content: 'No images here',
        createdAt: DateTime.now(),
      );

      expect(postWithImages.hasImages, true);
      expect(postWithoutImages.hasImages, false);
    });

    test('wasEdited returns true when editedAt is set', () {
      final editedPost = PostModel(
        id: 'test-id',
        authorId: 'author-1',
        authorName: 'Test User',
        content: 'Edited content',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        editedAt: DateTime.now(),
      );

      final newPost = PostModel(
        id: 'test-id-2',
        authorId: 'author-1',
        authorName: 'Test User',
        content: 'New content',
        createdAt: DateTime.now(),
      );

      expect(editedPost.wasEdited, true);
      expect(newPost.wasEdited, false);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = PostModel(
        id: 'test-id',
        authorId: 'author-1',
        authorName: 'Test User',
        content: 'Original content',
        likesCount: 5,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(likesCount: 10, content: 'Updated');

      expect(updated.likesCount, 10);
      expect(updated.content, 'Updated');
      expect(updated.id, original.id);
      expect(updated.authorName, original.authorName);
    });
  });

  group('EventModel Tests', () {
    test('creates event with required fields', () {
      final event = EventModel(
        id: 'event-1',
        title: 'Campus Party',
        description: 'A fun event',
        organizerId: 'org-1',
        organizerName: 'Student Council',
        location: 'Main Quad',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
        createdAt: DateTime.now(),
      );

      expect(event.title, 'Campus Party');
      expect(event.location, 'Main Quad');
      expect(event.attendeesCount, 0);
    });

    test('isFull returns true when at capacity', () {
      final fullEvent = EventModel(
        id: 'event-1',
        title: 'Limited Event',
        description: 'Only 10 spots',
        organizerId: 'org-1',
        organizerName: 'Organizer',
        location: 'Room 101',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        maxAttendees: 10,
        attendeesCount: 10,
        createdAt: DateTime.now(),
      );

      final openEvent = EventModel(
        id: 'event-2',
        title: 'Open Event',
        description: 'Plenty of room',
        organizerId: 'org-1',
        organizerName: 'Organizer',
        location: 'Auditorium',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        maxAttendees: 100,
        attendeesCount: 50,
        createdAt: DateTime.now(),
      );

      expect(fullEvent.isFull, true);
      expect(openEvent.isFull, false);
    });

    test('isUpcoming returns true for future events', () {
      final futureEvent = EventModel(
        id: 'event-1',
        title: 'Future Event',
        description: 'Coming soon',
        organizerId: 'org-1',
        organizerName: 'Organizer',
        location: 'TBD',
        startTime: DateTime.now().add(const Duration(days: 7)),
        endTime: DateTime.now().add(const Duration(days: 7, hours: 2)),
        createdAt: DateTime.now(),
      );

      expect(futureEvent.isUpcoming, true);
    });
  });

  group('ClubModel Tests', () {
    test('creates club with required fields', () {
      final club = ClubModel(
        id: 'club-1',
        name: 'Chess Club',
        description: 'For chess enthusiasts',
        category: 'Academic',
        adminIds: ['admin-1'],
        createdAt: DateTime.now(),
      );

      expect(club.name, 'Chess Club');
      expect(club.category, 'Academic');
      expect(club.membersCount, 0);
      expect(club.isVerified, false);
    });

    test('isAdmin returns true for admin users', () {
      final club = ClubModel(
        id: 'club-1',
        name: 'Test Club',
        description: 'Test',
        category: 'Social',
        adminIds: ['admin-1', 'admin-2'],
        createdAt: DateTime.now(),
      );

      expect(club.isAdmin('admin-1'), true);
      expect(club.isAdmin('admin-2'), true);
      expect(club.isAdmin('regular-user'), false);
    });
  });
}
