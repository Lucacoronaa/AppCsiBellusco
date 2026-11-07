import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/features/team/data/firestore_team_repository.dart';
import 'package:squadra_csi/features/team/domain/invite_code.dart';
import 'package:squadra_csi/features/team/domain/team.dart';
import 'package:squadra_csi/features/team/domain/team_failure.dart';
import 'package:squadra_csi/features/team/domain/team_member.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreTeamRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreTeamRepository(firestore);
  });

  Future<Team> createTestTeam() {
    return repository.createTeam(
      userId: 'u1',
      memberName: 'Luca',
      teamName: 'Real Bellusco',
    );
  }

  group('createTeam', () {
    test(
      'crea squadra, dirigente, codice invito e collegamento utente',
      () async {
        final team = await repository.createTeam(
          userId: 'u1',
          memberName: 'Luca',
          teamName: '  Real Bellusco  ',
        );

        expect(team.name, 'Real Bellusco');
        expect(isValidInviteCodeFormat(team.inviteCode), isTrue);

        final member = await firestore.doc('teams/${team.id}/members/u1').get();
        expect(member.data()?['role'], 'manager');

        final code = await firestore
            .doc('inviteCodes/${team.inviteCode}')
            .get();
        expect(code.data()?['teamId'], team.id);

        final user = await firestore.doc('users/u1').get();
        expect(user.data()?['teamId'], team.id);
      },
    );

    test('rifiuta chi ha già una squadra', () async {
      await firestore.doc('users/u1').set({'teamId': 'altra-squadra'});

      await expectLater(createTestTeam(), throwsA(isA<AlreadyInTeam>()));
    });
  });

  group('joinTeam', () {
    test('aggiunge un giocatore con un codice valido', () async {
      final team = await createTestTeam();

      final joined = await repository.joinTeam(
        userId: 'u2',
        memberName: 'Marco',
        inviteCode: ' ${team.inviteCode.toLowerCase()} ',
      );

      expect(joined.id, team.id);
      final member = await firestore.doc('teams/${team.id}/members/u2').get();
      expect(member.data()?['role'], 'player');
    });

    test('rifiuta un codice che non esiste', () async {
      await expectLater(
        repository.joinTeam(
          userId: 'u2',
          memberName: 'Marco',
          inviteCode: 'ABCDEF',
        ),
        throwsA(isA<InvalidInviteCode>()),
      );
    });

    test('rifiuta un codice con formato non valido', () async {
      await expectLater(
        repository.joinTeam(
          userId: 'u2',
          memberName: 'Marco',
          inviteCode: 'AB0',
        ),
        throwsA(isA<InvalidInviteCode>()),
      );
    });
  });

  group('watchMembers', () {
    test('emette i membri in ordine alfabetico', () async {
      final team = await createTestTeam();
      await repository.joinTeam(
        userId: 'u2',
        memberName: 'Andrea',
        inviteCode: team.inviteCode,
      );

      expect(
        repository.watchMembers(team.id),
        emits(
          isA<List<TeamMember>>().having(
            (members) => members.map((m) => m.displayName).toList(),
            'nomi',
            ['Andrea', 'Luca'],
          ),
        ),
      );
    });
  });

  group('watchTeamOf', () {
    test("emette null se l'utente non ha una squadra", () {
      expect(repository.watchTeamOf('u1'), emits(isNull));
    });

    test("emette la squadra dell'utente", () async {
      await createTestTeam();

      final team = await repository
          .watchTeamOf('u1')
          .firstWhere((team) => team != null);

      expect(team?.name, 'Real Bellusco');
    });
  });
}
