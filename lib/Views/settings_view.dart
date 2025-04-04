import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/Views/profile_view.dart';
import 'package:lottie/lottie.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          tr('settings.title'),
          style: const TextStyle(
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
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kToolbarHeight - // subtract AppBar height
                  32, // subtract the padding (16 top + 16 bottom)
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language change card
                  Card(
                    color: const Color(0xffffa400),
                      child: ListTile(
                        leading: const Icon(
                          Icons.language,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                        title: Row(
                          children: [
                            DropdownButton<Locale>(
                              value: context.locale,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color.fromARGB(255, 50, 50, 50),
                              ),
                              underline:
                                  Container(), // Removes the default underline
                              onChanged: (Locale? newLocale) {
                                if (newLocale != null) {
                                  context.setLocale(newLocale);
                                }
                              },
                              items: context.supportedLocales.map((locale) {
                                final languageName =
                                    locale.languageCode.toUpperCase();
                                return DropdownMenuItem<Locale>(
                                  value: locale,
                                  child: Text(
                                    languageName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xffffa400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Lottie.asset(
                              'assets/animations/lacis4.json',
                              height: 150,
                              width: 150,
                              fit: BoxFit.fill,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                tr('settings.mission_desctiption'),
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
                  const SizedBox(height: 16),
                  // Loop through each subject key and display its missions
                  ...subjectKeys.map((subject) {
                    return Card(
                      color: const Color(0xffffee9ae),
                        child: ExpansionTile(
                          iconColor: const Color(0xffffa400),
                          collapsedIconColor: const Color.fromARGB(255, 50, 50, 50),
                          title: Text(
                            tr('subjects.$subject.title'),
                            style: const TextStyle(
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
                                  color: Color.fromARGB(255, 50, 50, 50),
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }),
                        ),
                    );
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
