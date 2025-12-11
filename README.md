# QuadConnect

**The digital heartbeat of campus life** - A social networking platform designed specifically for students to connect, share, and engage with their campus community.

## About

QuadConnect closes the gap between classmates, clubs, and courses, creating a hyper-relevant social layer for academic life where students discover study partners, rally for events, and build lasting connections.

## Features

### ✅ Core Features

- **Authentication & Student Profiles** - Secure email/password authentication with customizable student profiles
- **Dynamic News Feed** - Real-time feed with posts, images, likes, and comments
- **Social Engagement System** - Like, comment, and share posts with threaded comments
- **Direct Messaging** - Real-time messaging with typing indicators and unread counts
- **Push Notifications** - Stay connected with real-time updates (ready for implementation)
- **Campus Events & Club Hub** - Discover, promote, and RSVP to campus events and club meetings

### 🎨 Design Highlights

- Modern, polished UI with Material Design 3
- Smooth animations and transitions
- Optimized image loading with caching
- Responsive layouts for all screen sizes
- Beautiful color scheme and typography

## Tech Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Navigation**: GoRouter
- **Image Caching**: cached_network_image

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Firebase project configured
- iOS/Android development environment set up

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Osman-OO/QuadConnect.git
cd QuadConnect
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Core utilities, theme, widgets
├── features/       # Feature modules
│   ├── auth/      # Authentication
│   ├── feed/      # News feed
│   ├── events/    # Events & clubs
│   ├── messages/  # Direct messaging
│   └── profile/   # User profiles
├── router/        # Navigation routing
└── services/      # Firebase services
```

## Key Features Implementation

### Real-time Feed
- Efficient pagination for large feeds
- Optimized image loading with caching
- Real-time updates via Firestore streams

### Messaging System
- Real-time message delivery
- Typing indicators
- Unread message counts
- Conversation management

### Events System
- Event creation and discovery
- RSVP with capacity management
- Category filtering
- Event details and attendees

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is private and proprietary.

## Contact

For questions or support, please open an issue on GitHub.
