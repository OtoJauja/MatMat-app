import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save mission progress for a given user, subject, and mission number.
  /// The document is named `subject` (e.g. "calm_Addition") under
  /// /users/{userId}/missions/{subject}.
  /// The array 'missions' holds objects with keys:
  /// { "missionNumber": int, "correctAnswers": int, "isCompleted": bool }
  Future<void> updateMissionProgress({
    required String userId,
    required String subject,
    required int missionNumber,
    required int newScore,
  }) async {
    // e.g. docRef for "calm_Addition" under /users/{userId}/missions
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('missions')
        .doc(subject);

    final docSnapshot = await docRef.get();

    // If no document yet, create an empty array
    List<dynamic> missionsArray = [];
    if (docSnapshot.exists) {
      missionsArray = docSnapshot.get('missions');
    }

    // Find the mission with the given missionNumber
    final index = missionsArray.indexWhere(
      (mission) => mission['missionNumber'] == missionNumber,
    );

    if (index != -1) {
      // Update only if newScore is higher
      final currentScore = missionsArray[index]['correctAnswers'] as int;
      if (newScore > currentScore) {
        missionsArray[index]['correctAnswers'] = newScore;
        missionsArray[index]['isCompleted'] = newScore >= 15;
      }
    } else {
      // If it doesn't exist, add it
      missionsArray.add({
        'missionNumber': missionNumber,
        'correctAnswers': newScore,
        'isCompleted': newScore >= 15,
      });
    }

    // Write back to Firestore
    await docRef.set({'missions': missionsArray});
  }

  /// Load mission progress for a given user and subject
  /// Returns an array of mission objects
  Future<List<dynamic>> loadMissionProgress({
    required String userId,
    required String subject,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('missions')
        .doc(subject);

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      return docSnapshot.get('missions') as List<dynamic>;
    } else {
      // Return an empty list if no data
      return [];
    }
  }
}