import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/features/auth/data/auth_repository_provider.dart';
import 'package:squadra_csi/features/auth/domain/app_user.dart';
import 'package:squadra_csi/features/team/data/team_repository_provider.dart';
import 'package:squadra_csi/features/team/domain/team_failure.dart';
import 'package:squadra_csi/features/team/presentation/team_setup_page.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_team_repository.dart';

const _testUser = AppUser(id: 'test-user', email: 'mario@example.com');

Widget _buildPage(FakeTeamRepository teamRepository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(initialUser: _testUser),
      ),
      teamRepositoryProvider.overrideWithValue(teamRepository),
    ],
    child: const MaterialApp(home: TeamSetupPage()),
  );
}

void main() {
  final nameField = find.widgetWithText(TextFormField, 'Il tuo nome');

  testWidgets('mostra un errore se il codice invito non esiste', (
    tester,
  ) async {
    final repository = FakeTeamRepository()
      ..joinFailure = const InvalidInviteCode();
    await tester.pumpWidget(_buildPage(repository));

    await tester.enterText(nameField, 'Marco');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Codice invito'),
      'ABCDEF',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Entra in squadra'));
    await tester.pumpAndSettle();

    expect(find.text('Codice invito non valido.'), findsOneWidget);
  });

  testWidgets('crea una squadra', (tester) async {
    final repository = FakeTeamRepository();
    await tester.pumpWidget(_buildPage(repository));

    await tester.tap(find.text('Crea squadra'));
    await tester.pumpAndSettle();

    await tester.enterText(nameField, 'Luca');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome della squadra'),
      'Real Bellusco',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Crea squadra'));
    await tester.pumpAndSettle();

    expect(repository.currentTeam?.name, 'Real Bellusco');
  });
}
