import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:squadra_csi/features/team/domain/invite_code.dart';
import 'package:squadra_csi/features/team/domain/team.dart';
import 'package:squadra_csi/features/team/domain/team_failure.dart';
import 'package:squadra_csi/features/team/domain/team_member.dart';
import 'package:squadra_csi/features/team/domain/team_repository.dart';
import 'package:squadra_csi/features/team/domain/team_role.dart';

class FirestoreTeamRepository implements TeamRepository {
  FirestoreTeamRepository(this._firestore);

  static const _maxInviteCodeAttempts = 5;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _teams =>
      _firestore.collection('teams');

  CollectionReference<Map<String, dynamic>> get _inviteCodes =>
      _firestore.collection('inviteCodes');

  @override
  Stream<Team?> watchTeamOf(String userId) {
    return _users.doc(userId).snapshots().switchMap((userSnapshot) {
      final teamId = userSnapshot.data()?['teamId'] as String?;
      if (teamId == null) {
        return Stream<Team?>.value(null);
      }
      return _teams.doc(teamId).snapshots().map(_toTeam);
    });
  }

  @override
  Stream<List<TeamMember>> watchMembers(String teamId) {
    return _teams
        .doc(teamId)
        .collection('members')
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_toMember).toList());
  }

  @override
  Future<Team> createTeam({
    required String userId,
    required String memberName,
    required String teamName,
  }) async {
    final teamRef = _teams.doc();
    final name = teamName.trim();

    try {
      final inviteCode = await _firestore.runTransaction((transaction) async {
        await _ensureNotInTeam(transaction, userId);
        final code = await _findFreeInviteCode(transaction);

        transaction
          ..set(teamRef, {
            'name': name,
            'inviteCode': code,
            'createdBy': userId,
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..set(teamRef.collection('members').doc(userId), {
            'displayName': memberName.trim(),
            'role': TeamRole.manager.name,
            'joinedAt': FieldValue.serverTimestamp(),
          })
          ..set(_inviteCodes.doc(code), {'teamId': teamRef.id})
          ..set(_users.doc(userId), {
            'teamId': teamRef.id,
          }, SetOptions(merge: true));

        return code;
      });

      return Team(id: teamRef.id, name: name, inviteCode: inviteCode);
    } on TeamFailure {
      rethrow;
    } on FirebaseException {
      throw const UnknownTeamFailure();
    }
  }

  @override
  Future<Team> joinTeam({
    required String userId,
    required String memberName,
    required String inviteCode,
  }) async {
    final code = normalizeInviteCode(inviteCode);
    if (!isValidInviteCodeFormat(code)) {
      throw const InvalidInviteCode();
    }

    try {
      final teamId = await _firestore.runTransaction((transaction) async {
        await _ensureNotInTeam(transaction, userId);

        final codeSnapshot = await transaction.get(_inviteCodes.doc(code));
        final teamId = codeSnapshot.data()?['teamId'] as String?;
        if (teamId == null) {
          throw const InvalidInviteCode();
        }

        transaction
          ..set(_teams.doc(teamId).collection('members').doc(userId), {
            'displayName': memberName.trim(),
            'role': TeamRole.player.name,
            'inviteCode': code,
            'joinedAt': FieldValue.serverTimestamp(),
          })
          ..set(_users.doc(userId), {
            'teamId': teamId,
          }, SetOptions(merge: true));

        return teamId;
      });

      final team = _toTeam(await _teams.doc(teamId).get());
      if (team == null) {
        throw const UnknownTeamFailure();
      }
      return team;
    } on TeamFailure {
      rethrow;
    } on FirebaseException {
      throw const UnknownTeamFailure();
    }
  }

  Future<void> _ensureNotInTeam(Transaction transaction, String userId) async {
    final userSnapshot = await transaction.get(_users.doc(userId));
    if (userSnapshot.data()?['teamId'] != null) {
      throw const AlreadyInTeam();
    }
  }

  Future<String> _findFreeInviteCode(Transaction transaction) async {
    for (var attempt = 0; attempt < _maxInviteCodeAttempts; attempt++) {
      final code = generateInviteCode();
      final snapshot = await transaction.get(_inviteCodes.doc(code));
      if (!snapshot.exists) {
        return code;
      }
    }
    throw const UnknownTeamFailure();
  }

  Team? _toTeam(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    return Team(
      id: snapshot.id,
      name: data['name'] as String,
      inviteCode: data['inviteCode'] as String,
    );
  }

  TeamMember _toMember(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return TeamMember(
      userId: snapshot.id,
      displayName: data['displayName'] as String,
      role: TeamRole.values.byName(data['role'] as String),
    );
  }
}
