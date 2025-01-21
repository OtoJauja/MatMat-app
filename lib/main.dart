import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';
import 'mission_provider.dart'; // Mission provider

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MissionsProvider(), // Provides the MissionsProvider to the app
      child: const MaterialApp(
        home: MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}