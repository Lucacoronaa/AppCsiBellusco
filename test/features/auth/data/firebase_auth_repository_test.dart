import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:squadra_csi/features/auth/data/firebase_auth_repository.dart';
import 'package:squadra_csi/features/auth/domain/app_user.dart';
import 'package:squadra_csi/features/auth/domain/auth_failure.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth;

class _MockUser extends Mock implements User;

class _MockUserCredential extends Mock implements UserCredential;

void main() {
  late _MockFirebaseAuth firebaseAuth;
  late FirebaseAuthRepository repository;

  setUp(() {
    firebaseAuth = _MockFirebaseAuth();
    repository = FirebaseAuthRepository(firebaseAuth);
  });

  group('authStateChanges', () {
    test("converte l'utente Firebase in AppUser", () {
      final user = _MockUser();
      when(() => user.uid).thenReturn('abc123');
      when(() => user.email).thenReturn('mario@example.com');
      when(() => user.displayName).thenReturn('Mario');
      when(() => firebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(user));

      expect(
        repository.authStateChanges(),
        emits(
          isA<AppUser>()
              .having((u) => u.id, 'id', 'abc123')
              .having((u) => u.email, 'email', 'mario@example.com'),
        ),
      );
    });

    test('emette null quando nessuno è autenticato', () {
      when(() => firebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(null));

      expect(repository.authStateChanges(), emits(isNull));
    });
  });

  group('signInWithEmailAndPassword', () {
    test("passa a Firebase l'email senza spazi", () async {
      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _MockUserCredential());

      await repository.signInWithEmailAndPassword(
        email: '  mario@example.com ',
        password: 'segreta1',
      );

      verify(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: 'mario@example.com',
          password: 'segreta1',
        ),
      ).called(1);
    });

    test('traduce le credenziali errate in InvalidCredentials', () async {
      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await expectLater(
        repository.signInWithEmailAndPassword(
          email: 'mario@example.com',
          password: 'sbagliata',
        ),
        throwsA(isA<InvalidCredentials>()),
      );
    });
  });

  group('createUserWithEmailAndPassword', () {
    test("traduce l'email già usata in EmailAlreadyInUse", () async {
      when(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      await expectLater(
        repository.createUserWithEmailAndPassword(
          email: 'mario@example.com',
          password: 'segreta1',
        ),
        throwsA(isA<EmailAlreadyInUse>()),
      );
    });
  });
}
