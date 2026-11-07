import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squadra_csi/features/auth/presentation/auth_state_provider.dart';
import 'package:squadra_csi/features/team/data/team_repository_provider.dart';
import 'package:squadra_csi/features/team/domain/team.dart';
import 'package:squadra_csi/features/team/domain/team_member.dart';

final currentTeamProvider = StreamProvider<Team?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(teamRepositoryProvider).watchTeamOf(user.id);
});

final teamMembersProvider = StreamProvider<List<TeamMember>>((ref) {
  final team = ref.watch(currentTeamProvider).value;
  if (team == null) {
    return Stream.value(const []);
  }
  return ref.watch(teamRepositoryProvider).watchMembers(team.id);
});
