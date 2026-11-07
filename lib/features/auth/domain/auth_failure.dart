sealed class AuthFailure implements Exception {
  const AuthFailure();
}

final class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();
}

final class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse();
}

final class WeakPassword extends AuthFailure {
  const WeakPassword();
}

final class NetworkFailure extends AuthFailure {
  const NetworkFailure();
}

final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure();
}
