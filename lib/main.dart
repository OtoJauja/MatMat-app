import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';
import 'mission_provider_calm.dart'; // Import for MissionProviderCalm
import 'mission_provider_fast.dart'; // Import for MissionProviderFast

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MissionsProviderCalm()),
        ChangeNotifierProvider(create: (_) => MissionsProviderFast()),
      ],
      child: const MaterialApp(
        home: MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}