import 'package:flutter/material.dart';
import 'mission_view_calm.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

class SubjectsViewCalm extends StatelessWidget {
  const SubjectsViewCalm({super.key});

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('subjects_screen.title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: const Color(0xffffa400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Lottie.asset(
                        'assets/animations/lacis1.json',
                        height: 150,
                        width: 150,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          tr('subject_view.brave_bear_description'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 50, 50, 50),
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ...subjectKeys.map((subjectKey) {
              return ListTile(
                title: Text(
                  tr('subject_view.$subjectKey'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MissionViewCalm(subjectName: subjectKey),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
