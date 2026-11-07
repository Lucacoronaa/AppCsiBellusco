import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:squadra_csi/features/auth/domain/app_user.dart';
import 'package:squadra_csi/features/auth/domain/auth_failure.dart';
import 'package:squadra_csi/features/auth/domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_toAppUser);
  }

  @override
  AppUser? get currentUser => _toAppUser(_firebaseAuth.currentUser);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (exception) {
      throw _toAuthFailure(exception);
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (exception) {
      throw _toAuthFailure(exception);
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  AppUser? _toAppUser(User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  AuthFailure _toAuthFailure(FirebaseAuthException exception) {
    return switch (exception.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-email' => const InvalidCredentials(),
      'email-already-in-use' => const EmailAlreadyInUse(),
      'weak-password' => const WeakPassword(),
      'network-request-failed' => const NetworkFailure(),
      _ => _unknownFailure(exception),
    };
  }

  AuthFailure _unknownFailure(FirebaseAuthException exception) {
    debugPrint(
      'Errore di autenticazione non gestito: '
      '${exception.code} - ${exception.message}',
    );
    return const UnknownAuthFailure();
  }
}
