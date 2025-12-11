import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/performance_utils.dart';
import 'router/app_router.dart';

void main() async {
  final stopwatch = Stopwatch()..start();

  WidgetsFlutterBinding.ensureInitialized();

  // Run initialization in parallel for faster startup
  await Future.wait([
    // Initialize Firebase
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);

  // Configure image cache for optimal performance
  PerformanceUtils.configureImageCache();

  // Set system UI overlay style (non-async, so separate)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  stopwatch.stop();
  if (kDebugMode) {
    debugPrint('🚀 App initialized in ${stopwatch.elapsedMilliseconds}ms');
  }

  runApp(const ProviderScope(child: QuadConnectApp()));
}

/// QuadConnect - Student Social Network
/// The digital heartbeat of campus life
class QuadConnectApp extends ConsumerWidget {
  const QuadConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'QuadConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
