import 'package:flutter/material.dart';
import 'package:flutter_app/Views/profile_view.dart';
import 'subjects_view_fast.dart';
import 'subjects_view_calm.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate card width based on screen size
    final cardWidth = screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Choose mode!',
          style: TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.account_circle,
                size: 32,
                color: Color.fromARGB(255, 50, 50, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileView()),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModeCard(
                icon: Icons.pets,
                title: 'Calm Bear',
                subtitle: 'Complete the tasks at your own pace',
                width: cardWidth,
                onStartPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubjectsViewCalm()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ModeCard(
                icon: Icons.local_florist,
                title: 'Fast Bee',
                subtitle: 'Complete the tasks in the given time',
                width: cardWidth,
                onStartPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SubjectsViewFast()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double width;
  final VoidCallback onStartPressed;

  const ModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.width,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: const Color(0xffffee9ae),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color.fromARGB(255, 50, 50, 50)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Mali',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 50, 50, 50),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Mali',
                fontSize: 14,
                color: Color.fromARGB(255, 50, 50, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onStartPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffffa400),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  fontFamily: 'Mali',
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}