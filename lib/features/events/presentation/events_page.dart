import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profilo',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: const Center(child: Text('Nessuna partita in programma')),
    );
  }
}
