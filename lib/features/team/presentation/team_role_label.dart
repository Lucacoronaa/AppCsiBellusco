import 'package:squadra_csi/features/team/domain/team_role.dart';

extension TeamRoleLabel on TeamRole {
  String get label => switch (this) {
    TeamRole.coach => 'Mister',
    TeamRole.manager => 'Dirigente',
    TeamRole.player => 'Giocatore',
  };
}
