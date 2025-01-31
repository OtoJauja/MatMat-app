import 'package:flutter/foundation.dart';

class Mission {
  final int number;
  int correctAnswers;
  bool isCompleted;

  Mission({required this.number, this.correctAnswers = 0, this.isCompleted = false});

  void updateCorrectAnswers(int answers) {
    correctAnswers = answers;
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
    "Exponentiation":List.generate(10, (index) => Mission(number: index + 1)),
    "Percentages": List.generate(10, (index) => Mission(number: index + 1)),
    "Sequences": List.generate(10, (index) => Mission(number: index + 1)),
  };

  List<Mission> getMissionsForSubject(String subject) {
    return _missions[subject] ?? [];
  }

  int getCompletedMissionsCount(String subject) {
    return _missions[subject]?.where((mission) => mission.isCompleted).length ?? 0;
  }

  void updateMissionProgress(String subject, int missionNumber, int correctAnswers) {
    final mission = _missions[subject]?.firstWhere((m) => m.number == missionNumber);
    if (mission != null) {
      mission.updateCorrectAnswers(correctAnswers);
      notifyListeners();
    }
  }
}