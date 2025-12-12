import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../../../services/auth_service.dart';


// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Stream of Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Current user model provider (loads from Firestore)
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authServiceProvider).getCurrentUserModel();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Auth state for UI (loading, error handling)
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => errorMessage != null;
}

/// Auth notifier for handling auth actions using Riverpod 2.0 Notifier
class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _init();
    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _authSubscription?.cancel();
    });
    return const AuthState();
  }

  void _init() {
    _authSubscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        final userModel = await _authService.getCurrentUserModel();
        state = AuthState(status: AuthStatus.authenticated, user: userModel);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.success) {
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    } else {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: result.errorMessage,
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success) {
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    } else {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: result.errorMessage,
      );
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> sendPasswordReset(String email) async {
    final result = await _authService.sendPasswordResetEmail(email);
    return result.success;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Main auth provider for UI using Riverpod 2.0 NotifierProvider
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
