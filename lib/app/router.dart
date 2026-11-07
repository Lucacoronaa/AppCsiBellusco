import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:squadra_csi/features/auth/presentation/auth_state_provider.dart';
import 'package:squadra_csi/features/auth/presentation/login_page.dart';
import 'package:squadra_csi/features/events/presentation/events_page.dart';
import 'package:squadra_csi/features/profile/presentation/profile_page.dart';
import 'package:squadra_csi/features/team/presentation/team_providers.dart';
import 'package:squadra_csi/features/team/presentation/team_setup_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref
    ..onDispose(refresh.dispose)
    ..listen(authStateChangesProvider, (_, _) => refresh.value++)
    ..listen(currentTeamProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final location = state.matchedLocation;

      if (authState.isLoading) {
        return null;
      }
      if (authState.value == null) {
        return location == '/login' ? null : '/login';
      }

      final teamState = ref.read(currentTeamProvider);
      if (teamState.isLoading) {
        return null;
      }
      if (teamState.value == null) {
        return location == '/team-setup' ? null : '/team-setup';
      }

      if (location == '/login' || location == '/team-setup') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const EventsPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/team-setup',
        builder: (context, state) => const TeamSetupPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
