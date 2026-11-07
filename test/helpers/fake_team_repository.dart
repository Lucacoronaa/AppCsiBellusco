import 'dart:async';

import 'package:squadra_csi/features/team/domain/team.dart';
import 'package:squadra_csi/features/team/domain/team_failure.dart';
import 'package:squadra_csi/features/team/domain/team_member.dart';
import 'package:squadra_csi/features/team/domain/team_repository.dart';

class FakeTeamRepository implements TeamRepository {
  FakeTeamRepository({this._team, this.members = const []});

  final List<TeamMember> members;
  final _teamController = StreamController<Team?>.broadcast();
  Team? _team;

  TeamFailure? joinFailure;

  Team? get currentTeam => _team;

  @override
  Stream<Team?> watchTeamOf(String userId) async* {
    yield _team;
    yield* _teamController.stream;
  }

  @override
  Stream<List<TeamMember>> watchMembers(String teamId) => Stream.value(members);

  @override
  Future<Team> createTeam({
    required String userId,
    required String memberName,
    required String teamName,
  }) async {
    final team = Team(id: 'team-1', name: teamName, inviteCode: 'ABC234');
    _emit(team);
    return team;
  }

  @override
  Future<Team> joinTeam({
    required String userId,
    required String memberName,
    required String inviteCode,
  }) async {
    final failure = joinFailure;
    if (failure != null) {
      throw failure;
    }
    final team = Team(
      id: 'team-1',
      name: 'Real Bellusco',
      inviteCode: inviteCode,
    );
    _emit(team);
    return team;
  }

  void _emit(Team team) {
    _team = team;
    _teamController.add(team);
  }
}
