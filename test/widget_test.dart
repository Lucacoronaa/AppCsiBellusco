import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/app/app.dart';

void main() {
  testWidgets('mostra la schermata del calendario', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.text('Calendario'), findsOneWidget);
  });

  testWidgets('apre il profilo dal calendario', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(find.text('Profilo'), findsOneWidget);
  });
}
