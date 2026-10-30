import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:squadra_csi/features/events/presentation/events_page.dart';
import 'package:squadra_csi/features/profile/presentation/profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const EventsPage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
