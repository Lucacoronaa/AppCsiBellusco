import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squadra_csi/features/team/presentation/team_providers.dart';

class StartupPage extends ConsumerWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamState = ref.watch(currentTeamProvider);

    return Scaffold(
      body: Center(
        child: teamState.hasError && !teamState.isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 16),
                  const Text('Impossibile caricare i dati della squadra.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(currentTeamProvider),
                    child: const Text('Riprova'),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
