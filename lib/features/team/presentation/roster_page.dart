import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squadra_csi/features/auth/presentation/auth_state_provider.dart';
import 'package:squadra_csi/features/team/presentation/team_providers.dart';
import 'package:squadra_csi/features/team/presentation/team_role_label.dart';

class RosterPage extends ConsumerWidget {
  const RosterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(currentTeamProvider).value;
    final membersState = ref.watch(teamMembersProvider);
    final currentUserId = ref.watch(authStateChangesProvider).value?.id;

    return Scaffold(
      appBar: AppBar(title: Text(team?.name ?? 'Rosa')),
      body: membersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Impossibile caricare la rosa.')),
        data: (members) => ListView(
          children: [
            if (team != null) _InviteCodeCard(inviteCode: team.inviteCode),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${members.length} membri',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final member in members)
              ListTile(
                leading: CircleAvatar(
                  child: Text(member.displayName.characters.first),
                ),
                title: Text(member.displayName),
                subtitle: Text(member.role.label),
                trailing: member.userId == currentUserId
                    ? const Text('Tu')
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.inviteCode});

  final String inviteCode;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Codice copiato')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.vpn_key_outlined),
        title: const Text('Codice invito'),
        subtitle: Text(
          inviteCode,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(letterSpacing: 4),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copia codice',
          onPressed: () => _copy(context),
        ),
      ),
    );
  }
}
