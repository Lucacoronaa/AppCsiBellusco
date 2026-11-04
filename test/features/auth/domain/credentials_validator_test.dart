import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/features/auth/domain/credentials_validator.dart';

void main() {
  group('isValidEmail', () {
    test('accetta un indirizzo valido', () {
      expect(isValidEmail('mario@example.com'), isTrue);
    });

    test('ignora gli spazi iniziali e finali', () {
      expect(isValidEmail('  mario@example.com  '), isTrue);
    });

    test('rifiuta un indirizzo senza @', () {
      expect(isValidEmail('mario.example.com'), isFalse);
    });

    test('rifiuta una stringa vuota', () {
      expect(isValidEmail(''), isFalse);
    });
  });

  group('isValidPassword', () {
    test('accetta una password di almeno 6 caratteri', () {
      expect(isValidPassword('123456'), isTrue);
    });

    test('rifiuta una password troppo corta', () {
      expect(isValidPassword('12345'), isFalse);
    });
  });
}
