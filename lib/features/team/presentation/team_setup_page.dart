import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squadra_csi/features/auth/data/auth_repository_provider.dart';
import 'package:squadra_csi/features/team/data/team_repository_provider.dart';
import 'package:squadra_csi/features/team/domain/invite_code.dart';
import 'package:squadra_csi/features/team/domain/team_failure.dart';
import 'package:squadra_csi/features/team/domain/team_validators.dart';

enum _SetupMode { join, create }

class TeamSetupPage extends ConsumerStatefulWidget {
  const TeamSetupPage({super.key});

  @override
  ConsumerState<TeamSetupPage> createState() => _TeamSetupPageState();
}

class _TeamSetupPageState extends ConsumerState<TeamSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _memberNameController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  _SetupMode _mode = _SetupMode.join;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _memberNameController.dispose();
    _teamNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = ref.read(teamRepositoryProvider);
    try {
      switch (_mode) {
        case _SetupMode.create:
          await repository.createTeam(
            userId: user.id,
            memberName: _memberNameController.text,
            teamName: _teamNameController.text,
          );
        case _SetupMode.join:
          await repository.joinTeam(
            userId: user.id,
            memberName: _memberNameController.text,
            inviteCode: _inviteCodeController.text,
          );
      }
    } on TeamFailure catch (failure) {
      if (mounted) {
        setState(() => _errorMessage = _messageFor(failure));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _messageFor(TeamFailure failure) {
    return switch (failure) {
      InvalidInviteCode() => 'Codice invito non valido.',
      AlreadyInTeam() => 'Fai già parte di una squadra.',
      UnknownTeamFailure() => 'Si è verificato un errore. Riprova.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = _mode == _SetupMode.create;

    return Scaffold(
      appBar: AppBar(
        title: const Text('La tua squadra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Esci',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SegmentedButton<_SetupMode>(
              segments: const [
                ButtonSegment(
                  value: _SetupMode.join,
                  label: Text('Entra con codice'),
                  icon: Icon(Icons.login),
                ),
                ButtonSegment(
                  value: _SetupMode.create,
                  label: Text('Crea squadra'),
                  icon: Icon(Icons.add),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) => setState(() {
                _mode = selection.first;
                _errorMessage = null;
              }),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _memberNameController,
              decoration: const InputDecoration(
                labelText: 'Il tuo nome',
                helperText: 'Come ti vedranno i compagni nella rosa',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) => isValidMemberName(value ?? '')
                  ? null
                  : 'Da $minNameLength a $maxMemberNameLength caratteri.',
            ),
            const SizedBox(height: 16),
            if (isCreating)
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome della squadra',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => isValidTeamName(value ?? '')
                    ? null
                    : 'Da $minNameLength a $maxTeamNameLength caratteri.',
              )
            else
              TextFormField(
                controller: _inviteCodeController,
                decoration: const InputDecoration(
                  labelText: 'Codice invito',
                  helperText: 'Chiedilo a un compagno di squadra',
                ),
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                validator: (value) => isValidInviteCodeFormat(value ?? '')
                    ? null
                    : 'Il codice ha $inviteCodeLength caratteri.',
              ),
            const SizedBox(height: 24),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isCreating ? 'Crea squadra' : 'Entra in squadra'),
            ),
          ],
        ),
      ),
    );
  }
}
