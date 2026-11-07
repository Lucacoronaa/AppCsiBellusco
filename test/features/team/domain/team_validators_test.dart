import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/features/team/domain/team_validators.dart';

void main() {
  group('isValidTeamName', () {
    test('accetta un nome normale', () {
      expect(isValidTeamName('Real Bellusco'), isTrue);
    });

    test('rifiuta un nome di un solo carattere', () {
      expect(isValidTeamName(' A '), isFalse);
    });

    test('rifiuta un nome troppo lungo', () {
      expect(isValidTeamName('A' * (maxTeamNameLength + 1)), isFalse);
    });
  });

  group('isValidMemberName', () {
    test('accetta un nome normale', () {
      expect(isValidMemberName('Luca'), isTrue);
    });
  });
}
