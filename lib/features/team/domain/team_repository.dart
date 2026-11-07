import 'package:squadra_csi/features/team/domain/team.dart';
import 'package:squadra_csi/features/team/domain/team_member.dart';

abstract interface class TeamRepository {
  Stream<Team?> watchTeamOf(String userId);

  Stream<List<TeamMember>> watchMembers(String teamId);

  Future<Team> createTeam({
    required String userId,
    required String memberName,
    required String teamName,
  });

  Future<Team> joinTeam({
    required String userId,
    required String memberName,
    required String inviteCode,
  });
}
