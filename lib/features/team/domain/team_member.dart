import 'package:squadra_csi/features/team/domain/team_role.dart';

class TeamMember {
  const TeamMember({
    required this.userId,
    required this.displayName,
    required this.role,
  });

  final String userId;
  final String displayName;
  final TeamRole role;
}
