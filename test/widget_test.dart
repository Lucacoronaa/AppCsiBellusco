import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/app/app.dart';

void main() {
  testWidgets('mostra la schermata del calendario', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Calendario'), findsOneWidget);
  });
}
