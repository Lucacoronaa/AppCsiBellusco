const minNameLength = 2;
const maxTeamNameLength = 40;
const maxMemberNameLength = 30;

bool isValidTeamName(String name) {
  final length = name.trim().length;
  return length >= minNameLength && length <= maxTeamNameLength;
}

bool isValidMemberName(String name) {
  final length = name.trim().length;
  return length >= minNameLength && length <= maxMemberNameLength;
}
