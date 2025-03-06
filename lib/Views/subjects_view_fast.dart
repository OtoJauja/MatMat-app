import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'mission_view_fast.dart'; // Import Mission View

class SubjectsViewFast extends StatelessWidget {
  const SubjectsViewFast({super.key});

  @override
  Widget build(BuildContext context) {
    // Use subject keys that match your provider keys exactly.
    final List<String> subjectKeys = [
      "Addition",
      "Subtraction",
      "Multiplication",
      "Division",
      "Mixed operations",
      "Sequences",
      "Exponentiation",
      "Percentages",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Color.fromARGB(255, 50, 50, 50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('subjects_screen.title'),
          style: const TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: subjectKeys.length,
          itemBuilder: (context, index) {
            final subjectKey = subjectKeys[index];
            return ListTile(
              title: Text(
                tr('subject_view.$subjectKey'),
                style: const TextStyle(
                  fontFamily: 'Mali',
                  color: Color.fromARGB(255, 50, 50, 50),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color.fromARGB(255, 50, 50, 50),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MissionViewFast(subjectName: subjectKey),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}