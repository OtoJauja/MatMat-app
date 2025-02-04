import 'package:flutter/material.dart';

import 'mission_view_fast.dart'; // Import Mission View

class SubjectsViewFast extends StatelessWidget {
  const SubjectsViewFast({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
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
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: const Color.fromARGB(255, 50, 50, 50),
          ),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subjects',
          style: TextStyle(fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        child: ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                subjects[index],
                style: const TextStyle(fontFamily: 'Mali',
                  color: Color.fromARGB(255, 50, 50, 50),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: const Color.fromARGB(255, 50, 50, 50)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MissionViewFast(subjectName: subjects[index]),
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