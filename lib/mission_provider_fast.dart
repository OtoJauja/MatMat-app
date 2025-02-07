import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mission {
  final int number;
  int correctAnswers;
  bool isCompleted;

  Mission({required this.number, this.correctAnswers = 0, this.isCompleted = false});

  // Only update if the new score is higher
  void updateCorrectAnswers(int answers) {
    if (answers > correctAnswers) {
      correctAnswers = answers;
    }
    if (correctAnswers >= 15) {
      isCompleted = true;
    }
  }
}
class MissionsProviderFast with ChangeNotifier {
  final Map<String, List<Mission>> _missions = {
    "Addition": List.generate(10, (index) => Mission(number: index + 1)),
    "Subtraction": List.generate(10, (index) => Mission(number: index + 1)),
    "Multiplication": List.generate(10, (index) => Mission(number: index + 1)),
    "Division": List.generate(10, (index) => Mission(number: index + 1)),
    "Mixed operations": List.generate(10, (index) => Mission(number: index + 1)),
    "Exponentiation": List.generate(10, (index) => Mission(number: index + 1)),
    "Percentages": List.generate(10, (index) => Mission(number: index + 1)),
    "Sequences": List.generate(10, (index) => Mission(number: index + 1)),
  };

  List<Mission> getMissionsForSubject(String subject) {
    return _missions[subject] ?? [];
  }

  int getCompletedMissionsCount(String subject) {
    return _missions[subject]?.where((mission) => mission.isCompleted).length ?? 0;
  }

  // Load saved progress from SharedPreferences for a given subject
  Future<void> loadSavedProgress(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    final missions = _missions[subject];
    if (missions != null) {
      for (int i = 0; i < missions.length; i++) {
        // Use a subject‑specific key
        int savedScore = prefs.getInt("fast${subject}_highestScore_$i") ?? 0;
        missions[i].correctAnswers = savedScore;
        missions[i].isCompleted = savedScore >= 15;
      }
      notifyListeners();
    }
  }

  // Update mission only if new score is higher
  void updateMissionProgress(String subject, int missionNumber, int newScore) {
    final mission = _missions[subject]?.firstWhere((m) => m.number == missionNumber);
    if (mission != null) {
      mission.updateCorrectAnswers(newScore);
      notifyListeners();
    }
  }
}