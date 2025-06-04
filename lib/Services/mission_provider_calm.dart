import 'package:flutter/foundation.dart';
import 'package:flutter_app/Services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mission {
  final int number;
  int correctAnswers;
  bool isCompleted;

  Mission(
      {required this.number,
      this.correctAnswers = 0,
      this.isCompleted = false});

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

class MissionsProviderCalm with ChangeNotifier {
  final Map<String, List<Mission>> _missions = {
    "Addition": List.generate(10, (index) => Mission(number: index + 1)),
    "Subtraction": List.generate(10, (index) => Mission(number: index + 1)),
    "Multiplication": List.generate(10, (index) => Mission(number: index + 1)),
    "Division": List.generate(10, (index) => Mission(number: index + 1)),
    "Mixed operations":
        List.generate(10, (index) => Mission(number: index + 1)),
    "Exponentiation": List.generate(10, (index) => Mission(number: index + 1)),
    "Percentages": List.generate(10, (index) => Mission(number: index + 1)),
    "Sequences": List.generate(10, (index) => Mission(number: index + 1)),
  };

  List<Mission> getMissionsForSubject(String subject) {
    return _missions[subject] ?? [];
  }

  List<String> get subjectKeys => _missions.keys.toList();

  int getCompletedMissionsCount(String subject) {
    return _missions[subject]?.where((mission) => mission.isCompleted).length ??
        0;
  }

  // (Optional) Old local load from SharedPreferences
  Future<void> loadSavedProgress(String userId, String subject) async {
    final prefs = await SharedPreferences.getInstance();
    final missions = _missions[subject];
    if (missions != null) {
      for (int i = 0; i < missions.length; i++) {
        int savedScore =
            prefs.getInt("${userId}_calm_${subject}_correctAnswers_$i") ?? 0;
        missions[i].correctAnswers = savedScore;
        missions[i].isCompleted = savedScore >= 15;
      }
      notifyListeners();
    }
  }

  /// Load mission data from Firestore for user and subject
  Future<void> loadProgressFromFirestore(String userId, String subject) async {
    final firebaseService = FirebaseService();
    final missionsData = await firebaseService.loadMissionProgress(
      userId: userId,
      subject: "calm_$subject",
    );

    if (missionsData.isNotEmpty) {
      final localList = _missions[subject] ?? [];
      final prefs = await SharedPreferences.getInstance();
      for (var item in missionsData) {
        final missionNumber = item['missionNumber'] as int;
        final correctAnswers = item['correctAnswers'] as int;
        final isCompleted = item['isCompleted'] as bool;

        final localMission = localList.firstWhere(
          (m) => m.number == missionNumber,
          orElse: () => Mission(number: missionNumber),
        );
        localMission.correctAnswers = correctAnswers;
        localMission.isCompleted = isCompleted;

        // Save the updated progress locally
        await prefs.setInt(
            "${userId}_calm_${subject}_correctAnswers_${missionNumber - 1}",
            correctAnswers);
      }
      notifyListeners();
    }
  }

  /// Update mission progress, store in local memory and Firestore if userId is given
  void updateMissionProgress(String subject, int missionNumber, int newScore,
      {String? userId}) {
    final mission =
        _missions[subject]?.firstWhere((m) => m.number == missionNumber);
    if (mission != null) {
      mission.updateCorrectAnswers(newScore);
      notifyListeners();

      // If a userId is provided sync to Firestore
      if (userId != null) {
        final firebaseService = FirebaseService();
        firebaseService.updateMissionProgress(
          userId: userId,
          subject: "calm_$subject",
          missionNumber: missionNumber,
          newScore: newScore,
        );
      }
    }
  }
}
