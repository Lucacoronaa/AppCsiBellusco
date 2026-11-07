import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:squadra_csi/features/auth/domain/app_user.dart';
import 'package:squadra_csi/features/auth/presentation/auth_state_provider.dart';
import 'package:squadra_csi/features/auth/presentation/login_page.dart';
import 'package:squadra_csi/features/events/presentation/events_page.dart';
import 'package:squadra_csi/features/profile/presentation/profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AsyncValue<AppUser?>>(
    const AsyncLoading(),
  );

  ref
    ..onDispose(authNotifier.dispose)
    ..listen<AsyncValue<AppUser?>>(
      authStateChangesProvider,
      (_, next) => authNotifier.value = next,
      fireImmediately: true,
    );

  final router = GoRouter(
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.value;
      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = authState.value != null;
      final isOnLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isOnLoginPage ? null : '/login';
      }
      if (isOnLoginPage) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const EventsPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
