import 'package:daily_finance_tracker/domain/services/auth_service.dart';
import 'package:daily_finance_tracker/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: const ['email'],
    serverClientId: DefaultFirebaseOptions.googleWebClientId,
  );
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
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Google sign-in failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      state = const AsyncData(null);
      return _googleSignInErrorMessage(error);
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

String _googleSignInErrorMessage(Object error) {
  final message = error.toString();
  if (message.contains('ApiException: 10') ||
      message.contains('DEVELOPER_ERROR')) {
    return 'Google sign-in is misconfigured. Add your debug SHA-1 fingerprint '
        'in Firebase Console, re-download google-services.json, then rebuild.';
  }
  if (message.contains('network_error') || message.contains('NetworkError')) {
    return 'Network error during Google sign-in. Check your connection and try again.';
  }
  return 'Google sign-in failed. Check Firebase config and try again.';
}
