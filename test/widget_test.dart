import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/app/app.dart';
import 'package:squadra_csi/features/auth/data/auth_repository_provider.dart';
import 'package:squadra_csi/features/auth/domain/app_user.dart';
import 'package:squadra_csi/features/auth/presentation/login_page.dart';
import 'package:squadra_csi/features/team/data/team_repository_provider.dart';
import 'package:squadra_csi/features/team/domain/team.dart';
import 'package:squadra_csi/features/team/presentation/team_setup_page.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_team_repository.dart';

const _testUser = AppUser(id: 'test-user', email: 'mario@example.com');
const _testTeam = Team(
  id: 'team-1',
  name: 'Real Bellusco',
  inviteCode: 'ABC234',
);

Widget _buildApp({AppUser? user, Team? team}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(initialUser: user),
      ),
      teamRepositoryProvider.overrideWithValue(FakeTeamRepository(team: team)),
    ],
    child: const App(),
  );
}

void main() {
  testWidgets('mostra il login se nessuno è autenticato', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets("mostra il setup se l'utente non ha una squadra", (tester) async {
    await tester.pumpWidget(_buildApp(user: _testUser));
    await tester.pumpAndSettle();

    expect(find.byType(TeamSetupPage), findsOneWidget);
  });

  testWidgets("mostra il calendario se l'utente ha una squadra", (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(user: _testUser, team: _testTeam));
    await tester.pumpAndSettle();

    expect(find.text('Calendario'), findsOneWidget);
  });

  testWidgets('apre il profilo dal calendario', (tester) async {
    await tester.pumpWidget(_buildApp(user: _testUser, team: _testTeam));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(find.text('Profilo'), findsOneWidget);
    expect(find.text('mario@example.com'), findsOneWidget);
  });
}
