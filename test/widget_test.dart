import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/app/app.dart';
import 'package:squadra_csi/features/auth/data/auth_repository_provider.dart';
import 'package:squadra_csi/features/auth/domain/app_user.dart';
import 'package:squadra_csi/features/auth/presentation/login_page.dart';

import 'helpers/fake_auth_repository.dart';

const _testUser = AppUser(id: 'test-user', email: 'mario@example.com');

Widget _buildApp(FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: const App(),
  );
}

void main() {
  testWidgets('mostra il login se nessuno è autenticato', (tester) async {
    await tester.pumpWidget(_buildApp(FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets("mostra il calendario se l'utente è autenticato", (tester) async {
    await tester.pumpWidget(
      _buildApp(FakeAuthRepository(initialUser: _testUser)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Calendario'), findsOneWidget);
  });

  testWidgets('apre il profilo dal calendario', (tester) async {
    await tester.pumpWidget(
      _buildApp(FakeAuthRepository(initialUser: _testUser)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(find.text('Profilo'), findsOneWidget);
    expect(find.text('mario@example.com'), findsOneWidget);
  });
}
