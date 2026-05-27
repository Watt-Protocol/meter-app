import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

/// Singleton auth repository (waitlist_users + RPC login).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError(
    'authRepositoryProvider must be overridden in ProviderScope',
  );
});

/// Whether the user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authRepositoryProvider).isAuthenticated;
});

/// The current user's email, or null.
final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authRepositoryProvider).currentUserEmail;
});

/// The current user's id (`waitlist_users.id`, e.g. 2), or null.
final currentUserIdProvider = Provider<int?>((ref) {
  return ref.watch(authRepositoryProvider).currentUserId;
});
