import 'package:daily_finance_tracker/domain/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(scopes: const ['email']);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._authService) : super(const AsyncData(null));

  final AuthService _authService;

  Future<String?> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await _authService.signInWithGoogle();
      state = const AsyncData(null);
      return null;
    } on AuthCancelledException {
      state = const AsyncData(null);
      return 'Google sign-in cancelled.';
    } catch (_) {
      state = const AsyncData(null);
      return 'Google sign-in failed. Check Firebase config and try again.';
    }
  }

  Future<String?> signOut() async {
    state = const AsyncLoading();
    try {
      await _authService.signOut();
      state = const AsyncData(null);
      return null;
    } catch (_) {
      state = const AsyncData(null);
      return 'Sign-out failed. Please try again.';
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.watch(authServiceProvider));
    });
