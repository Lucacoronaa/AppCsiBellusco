import 'dart:async';

import 'package:squadra_csi/features/auth/domain/app_user.dart';
import 'package:squadra_csi/features/auth/domain/auth_failure.dart';
import 'package:squadra_csi/features/auth/domain/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _currentUser = initialUser;

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  AuthFailure? signInFailure;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final failure = signInFailure;
    if (failure != null) {
      throw failure;
    }
    _emit(AppUser(id: 'test-user', email: email));
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _emit(AppUser(id: 'test-user', email: email));
  }

  @override
  Future<void> signOut() async => _emit(null);

  void _emit(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }
}
