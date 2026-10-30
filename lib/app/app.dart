import 'package:flutter/material.dart';
import 'package:squadra_csi/features/events/presentation/events_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squadra CSI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const EventsPage(),
    );
  }
}
