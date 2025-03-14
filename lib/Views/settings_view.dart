import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/Views/profile_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the list of subject keys in JSON file
    final List<String> subjectKeys = [
      'addition',
      'subtraction',
      'multiplication',
      'division',
      'mixed_operations',
      'exponentiation',
      'percentages',
      'sequences'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          tr('settings.title'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Language change card
            Card(
              color: const Color.fromARGB(255, 142, 216, 251),
              child: ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Color.fromARGB(255, 50, 50, 50),
                ),
                title: Text(
                  tr('settings.change_language'),
                  style: const TextStyle(
                    fontFamily: 'Mali',
                    color: Color.fromARGB(255, 50, 50, 50),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  final currentLocale = context.locale;
                  final newLocale = currentLocale.languageCode == 'en'
                      ? const Locale('lv')
                      : const Locale('en');
                  context.setLocale(newLocale);
                },
              ),
            ),
            // Loop through each subject key and display its missions
            ...subjectKeys.map((subject) {
              // For each subject iterate through 10 missions
              return Card(
                color: const Color.fromARGB(255, 142, 216, 251),
                child: ExpansionTile(
                  title: Text(
                    tr('subjects.$subject.title'),
                    style: const TextStyle(
                      fontFamily: 'Mali',
                      color: Color.fromARGB(255, 50, 50, 50),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  children: List.generate(10, (index) {
                    final missionNumber = (index + 1).toString();
                    return ListTile(
                      title: Text(
                        '$missionNumber. ${tr("subjects.$subject.missions.$missionNumber")}',
                        style: const TextStyle(
                          fontFamily: 'Mali',
                          color: Color.fromARGB(255, 50, 50, 50),
                          fontSize: 16,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}