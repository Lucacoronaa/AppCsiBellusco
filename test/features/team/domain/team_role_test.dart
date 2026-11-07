import 'package:flutter_test/flutter_test.dart';
import 'package:squadra_csi/features/team/domain/team_role.dart';

void main() {
  test('il mister può pubblicare i convocati e gestire i membri', () {
    expect(TeamRole.coach.canPublishCallUps, isTrue);
    expect(TeamRole.coach.canManageMembers, isTrue);
  });

  test('il dirigente può pubblicare i convocati e gestire i membri', () {
    expect(TeamRole.manager.canPublishCallUps, isTrue);
    expect(TeamRole.manager.canManageMembers, isTrue);
  });

  test('il giocatore non può pubblicare i convocati né gestire i membri', () {
    expect(TeamRole.player.canPublishCallUps, isFalse);
    expect(TeamRole.player.canManageMembers, isFalse);
  });
}
