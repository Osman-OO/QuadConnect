import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Performance optimization utilities for QuadConnect
class PerformanceUtils {
  PerformanceUtils._();

  /// Configure image caching for optimal performance
  static void configureImageCache() {
    // Set max cache size (100 images in memory)
    PaintingBinding.instance.imageCache.maximumSize = 100;
    // Set max cache size in bytes (100MB)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;
  }

  /// Clear image cache to free memory
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Log performance metrics in debug mode
  static void logPerformance(String tag, Duration duration) {
    if (kDebugMode) {
      debugPrint('⏱️ [$tag] ${duration.inMilliseconds}ms');
    }
  }

  /// Measure execution time of async functions
  static Future<T> measureAsync<T>(
    String tag,
    Future<T> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await function();
    } finally {
      stopwatch.stop();
      logPerformance(tag, stopwatch.elapsed);
    }
  }

  /// Measure execution time of sync functions
  static T measureSync<T>(String tag, T Function() function) {
    final stopwatch = Stopwatch()..start();
    try {
      return function();
    } finally {
      stopwatch.stop();
      logPerformance(tag, stopwatch.elapsed);
    }
  }
}

/// Mixin to track widget rebuilds in debug mode
mixin RebuildTracker<T extends StatefulWidget> on State<T> {
  int _rebuildCount = 0;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      _rebuildCount++;
      if (_rebuildCount > 10) {
        debugPrint('⚠️ ${widget.runtimeType} rebuilt $_rebuildCount times');
      }
    }
    return buildWithTracking(context);
  }

  Widget buildWithTracking(BuildContext context);
}

/// Extension for lazy loading lists
extension LazyListExtension<T> on List<T> {
  /// Take only what's needed for current viewport
  List<T> lazyTake(int count) {
    if (length <= count) return this;
    return sublist(0, count);
  }
}

/// Debouncer for search and input fields
class Debouncer {
  final Duration delay;
  VoidCallback? _action;
  bool _isDisposed = false;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _action = action;
    Future.delayed(delay, () {
      if (!_isDisposed && _action == action) {
        action();
      }
    });
  }

  void dispose() {
    _isDisposed = true;
    _action = null;
  }
}

/// Throttler for scroll events and frequent updates
class Throttler {
  final Duration interval;
  DateTime? _lastActionTime;

  Throttler({this.interval = const Duration(milliseconds: 100)});

  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastActionTime == null ||
        now.difference(_lastActionTime!) >= interval) {
      _lastActionTime = now;
      action();
    }
  }
}
