enum TeamRole {
  coach,
  manager,
  player;

  bool get canPublishCallUps => this == coach || this == manager;

  bool get canManageMembers => this == coach || this == manager;
}
