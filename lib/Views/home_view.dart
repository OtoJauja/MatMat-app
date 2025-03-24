import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Views/profile_view.dart';
import 'package:lottie/lottie.dart';
import 'subjects_view_fast.dart';
import 'subjects_view_calm.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final cardWidth = orientation == Orientation.portrait
        ? screenSize.width * 0.85
        : screenSize.width * 0.3;

    final modeCards = <Widget>[
      ModeCard(
        animation: Lottie.asset(
          'assets/animations/lacis1.json',
          height: 150,
          width: 150,
          fit: BoxFit.fill,
        ),
        title: tr('home.calm_bear'),
        subtitle: tr('home.calm_subtitle'),
        width: cardWidth,
        onStartPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubjectsViewCalm()),
          );
        },
      ),
      const SizedBox(height: 25),
      ModeCard(
        animation: Lottie.asset(
          'assets/animations/B1.json',
          height: 150,
          width: 150,
          fit: BoxFit.fill,
        ),
        title: tr('home.fast_bee'),
        subtitle: tr('home.fast_subtitle'),
        width: cardWidth,
        onStartPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SubjectsViewFast()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          tr('home.title'),
          style: const TextStyle(
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
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: screenSize.height,
            minWidth: screenSize.width,
          ),
          alignment: Alignment.center,
          child: orientation == Orientation.portrait
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: modeCards,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    modeCards.first,
                    const SizedBox(width: 25),
                    modeCards.last,
                  ],
                ),
        ),
      ),
    );
  }
}

class ModeCard extends StatelessWidget {
  final LottieBuilder animation;
  final String title;
  final String subtitle;
  final double width;
  final VoidCallback onStartPressed;

  const ModeCard({
    super.key,
    required this.animation,
    required this.title,
    required this.subtitle,
    required this.width,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            animation,
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
              child: Text(
                tr('home.start'),
                style: const TextStyle(
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