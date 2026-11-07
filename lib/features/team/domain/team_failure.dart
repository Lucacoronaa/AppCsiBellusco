sealed class TeamFailure implements Exception {
  const TeamFailure();
}

final class InvalidInviteCode extends TeamFailure {
  const InvalidInviteCode();
}

final class AlreadyInTeam extends TeamFailure {
  const AlreadyInTeam();
}

final class UnknownTeamFailure extends TeamFailure {
  const UnknownTeamFailure();
}
