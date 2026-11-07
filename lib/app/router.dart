import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:squadra_csi/app/startup_page.dart';
import 'package:squadra_csi/features/auth/presentation/auth_state_provider.dart';
import 'package:squadra_csi/features/auth/presentation/login_page.dart';
import 'package:squadra_csi/features/events/presentation/events_page.dart';
import 'package:squadra_csi/features/profile/presentation/profile_page.dart';
import 'package:squadra_csi/features/team/presentation/roster_page.dart';
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
      const startup = '/startup';
      final location = state.matchedLocation;

      final authState = ref.read(authStateChangesProvider);
      if (authState.isLoading) {
        return location == startup ? null : startup;
      }
      if (authState.value == null) {
        return location == '/login' ? null : '/login';
      }

      final teamState = ref.read(currentTeamProvider);
      if (teamState.isLoading || teamState.hasError) {
        return location == startup ? null : startup;
      }
      if (teamState.value == null) {
        return location == '/team-setup' ? null : '/team-setup';
      }

      const entryPages = ['/login', '/team-setup', startup];
      if (entryPages.contains(location)) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const EventsPage()),
      GoRoute(
        path: '/startup',
        builder: (context, state) => const StartupPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/team-setup',
        builder: (context, state) => const TeamSetupPage(),
      ),
      GoRoute(path: '/team', builder: (context, state) => const RosterPage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
