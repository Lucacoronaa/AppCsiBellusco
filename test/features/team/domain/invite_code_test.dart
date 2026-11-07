import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/features/team/domain/invite_code.dart';

void main() {
  group('generateInviteCode', () {
    test('genera un codice della lunghezza giusta', () {
      expect(generateInviteCode(Random(1)), hasLength(inviteCodeLength));
    });

    test('genera solo caratteri validi', () {
      for (var seed = 0; seed < 50; seed++) {
        final code = generateInviteCode(Random(seed));
        expect(isValidInviteCodeFormat(code), isTrue, reason: code);
      }
    });
  });

  group('isValidInviteCodeFormat', () {
    test('accetta minuscole e spazi', () {
      expect(isValidInviteCodeFormat(' ab3k7z '), isTrue);
    });

    test('rifiuta i caratteri ambigui', () {
      expect(isValidInviteCodeFormat('AB0K7Z'), isFalse);
      expect(isValidInviteCodeFormat('ABIK7Z'), isFalse);
    });

    test('rifiuta un codice troppo corto', () {
      expect(isValidInviteCodeFormat('AB3K7'), isFalse);
    });
  });
}
