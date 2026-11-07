import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/features/auth/data/auth_repository_provider.dart';
import 'package:squadra_csi/features/auth/domain/auth_failure.dart';
import 'package:squadra_csi/features/auth/presentation/login_page.dart';

import '../../../helpers/fake_auth_repository.dart';

Widget _buildPage(FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: LoginPage()),
  );
}

void main() {
  final emailField = find.widgetWithText(TextFormField, 'Email');
  final passwordField = find.widgetWithText(TextFormField, 'Password');
  final signInButton = find.widgetWithText(FilledButton, 'Accedi');

  testWidgets('mostra gli errori di validazione con i campi vuoti', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage(FakeAuthRepository()));

    await tester.tap(signInButton);
    await tester.pump();

    expect(find.text("Inserisci un'email valida."), findsOneWidget);
    expect(find.text('Almeno 6 caratteri.'), findsOneWidget);
  });

  testWidgets('mostra un messaggio se le credenziali sono errate', (
    tester,
  ) async {
    final repository = FakeAuthRepository()
      ..signInFailure = const InvalidCredentials();
    await tester.pumpWidget(_buildPage(repository));

    await tester.enterText(emailField, 'mario@example.com');
    await tester.enterText(passwordField, 'sbagliata');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.text('Email o password non corretti.'), findsOneWidget);
  });

  testWidgets('esegue il login con credenziali valide', (tester) async {
    final repository = FakeAuthRepository();
    await tester.pumpWidget(_buildPage(repository));

    await tester.enterText(emailField, 'mario@example.com');
    await tester.enterText(passwordField, 'segreta1');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(repository.currentUser?.email, 'mario@example.com');
  });
}
