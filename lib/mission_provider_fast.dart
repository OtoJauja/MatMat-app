import 'package:flutter/foundation.dart';

class Mission {
  final int number;
  final String description;
  int? correctAnswers;

  Mission({
    required this.number,
    required this.description,
    this.correctAnswers,
  });
}

class MissionsProviderFast with ChangeNotifier {
  final Map<String, List<Mission>> _missions = {
    "Addition": [
      Mission(number: 1, description: "Add 1-Digit Numbers"),
      Mission(number: 2, description: "Add 1-Digit and 2-Digit Numbers"),
      Mission(number: 3, description: "Add 2-Digit Numbers Without Carrying"),
      Mission(number: 4, description: "Add 2-Digit Numbers With Carrying"),
      Mission(number: 5, description: "Adding 3-Digit and 2-Digit Numbers"),
      Mission(number: 6, description: "Adding 3-Digit and 3-Digit Numbers"),
      Mission(number: 7, description: "Adding 4-Digit and 2-Digit Numbers"),
      Mission(number: 8, description: "Adding 4-Digit and 3-Digit Numbers"),
      Mission(number: 9, description: "Adding 4-Digit and 4-Digit Numbers"),
      Mission(number: 10, description: "Addition of Decimals"),
    ],
    "Subtraction": [
      Mission(number: 1, description: "Subtracting 2-Digit and 1-Digit Numbers"),
      Mission(number: 2, description: "Subtracting 2-Digit Numbers"),
      Mission(number: 3, description: "Subtracting 3-Digit or 2-Digit or 1-Digit Numbers Without Carrying"),
      Mission(number: 4, description: "Subtracting 3-Digit or 2-Digit or 1-Digit Numbers With Carrying"),
      Mission(number: 5, description: "Subtracting 3-Digit and 2-Digit and 1-Digit Numbers"),
      Mission(number: 6, description: "Subtracting 3-Digit Numbers"),
      Mission(number: 7, description: "Subtracting 4-Digit and 2-Digit Numbers"),
      Mission(number: 8, description: "Subtracting 4-Digit and 3-Digit Numbers"),
      Mission(number: 9, description: "Subtracting 4-Digit and 4-Digit Numbers"),
      Mission(number: 10, description: "Subtraction of Decimals"),
    ],
    "Multiplication": [
      Mission(number: 1, description: "Multiplying 1-Digit Numbers"),
      Mission(number: 2, description: "Multiplying 1-Digit x 2-Digit Numbers"),
      Mission(number: 3, description: "Multiplying 2-Digit x 1-Digit Numbers"),
      Mission(number: 4, description: "Multiplying 3-Digit x 1-Digit Numbers or vice versa"),
      Mission(number: 5, description: "Multiplying 4-Digit x 1-Digit Numbers or vice versa"),
      Mission(number: 6, description: "Multiplying 2-Digit Numbers"),
      Mission(number: 7, description: "Multiplying 1-Digit x 1-Digit x 1-Digit Numbers"),
      Mission(number: 8, description: "Multiplying 2-Digit x 1-Digit x 1-Digit Numbers"),
      Mission(number: 9, description: "Multiplying Decimal Numbers by 1-Digit Numbers"),
      Mission(number: 10, description: "Multiplying Decimal Numbers"),
    ],
    "Division": [
      Mission(number: 1, description: "Divide 1-Digit Numbers"),
      Mission(number: 2, description: "Divide 2-Digit by 1-Digit Numbers"),
      Mission(number: 3, description: "Divide 3-Digit by 1-Digit Numbers"),
      Mission(number: 4, description: "Divide 4-Digit by 1-Digit Numbers"),
      Mission(number: 5, description: "Divide 2-Digit Numbers"),
      Mission(number: 6, description: "Divide 3-Digit by 2-Digit Numbers"),
      Mission(number: 7, description: "Divide 3-Digit by 1-Digit by 1-Digit Numbers"),
      Mission(number: 8, description: "Divide 4-Digit by 1-Digit by 1-Digit Numbers"),
      Mission(number: 9, description: "Divide Decimal Numbers by 1-Digit or 2-Digit Numbers"),
      Mission(number: 10, description: "Divide Decimal Numbers"),
    ],
    "Mixed operations": [
      Mission(number: 1, description: "(1-Digit + 1-Digit) x 1-Digit Numbers"),
      Mission(number: 2, description: "(1-Digit + 2-Digit) x 1-Digit Numbers"),
      Mission(number: 3, description: "1-Digit x (2-Digit + 2-Digit) Numbers"),
      Mission(number: 4, description: "1-Digit x 2-Digit + 1-Digit x 2-Digit Numbers"),
      Mission(number: 5, description: "1-Digit x 3-Digit - 2-Digit x 1-Digit Numbers"),
      Mission(number: 6, description: "2-Digit x 2-Digit - 2-Digit x 1-Digit Numbers"),
      Mission(number: 7, description: "(1-Digit + 1-Digit) x (1-Digit + 1-Digit) Numbers"),
      Mission(number: 8, description: "(2-Digit - 1-Digit) : 1-Digit Numbers"),
      Mission(number: 9, description: "(3-Digit + 2-Digit) : 1-Digit Numbers"),
      Mission(number: 10, description: "2-Digit x 1-Digit + 2-Digit x 2-Digit Numbers"),
    ],
    "Exponentiation": [
      Mission(number: 1, description: "1-Digit Squared"),
      Mission(number: 2, description: "2-Digit Squared"),
      Mission(number: 3, description: "1-Digit Cubed"),
      Mission(number: 4, description: "1-Digit Squared + 1-Digit Squared"),
      Mission(number: 5, description: "1-Digit Cubed - 1-Digit Squared"),
      Mission(number: 6, description: "Square root of 1-Digit, 2-Digit or 3-Digit Numbers"),
      Mission(number: 7, description: "Cubic root of 1-Digit, 2-Digit or 3-Digit Numbers"),
      Mission(number: 8, description: "Square root of 1-Digit or 2-Digit + 1-Digit Squared"),
      Mission(number: 9, description: "Square root of 2-Digit × square root of 2-Digit Numbers"),
      Mission(number: 10, description: "Square of 2-Digits Divided by the square root of 2-Digits or 3-Digits"),
    ],
    "Percentages": [
      Mission(number: 1, description: "10% of 2-Digit or 3-Digit Numbers"),
      Mission(number: 2, description: "20% of 2-Digit or 3-Digit (divisible by 5 without remainder)"),
      Mission(number: 3, description: "50% of 1-Digit, 2-Digit or 3-Digit"),
      Mission(number: 4, description: "20%, 25% or 50% of 2-Digit, 3-Digit or 4-Digit"),
      Mission(number: 5, description: "2-Digit + 10%, 20%, 25% or 50%"),
      Mission(number: 6, description: "2-Digit - 10%, 20%, 25% or 50%"),
      Mission(number: 7, description: "30% of 3-Digit"),
      Mission(number: 8, description: "3-Digit + 10%, 20%, 25% or 50%"),
      Mission(number: 9, description: "1-Digit % of 2-Digit Numbers"),
      Mission(number: 10, description: "2-Digit % of 2-Digit numbers"),
    ],
    "Sequences": [
      Mission(number: 1, description: "Start with 1; 2; 3 or 4 and add 1-Digit. For example, 4; 11; 18; 25; ..."),
      Mission(number: 2, description: "Start with 2-Digit numbers and add 1-Digit numbers. For example, 23; 28; 33; 38; ..."),
      Mission(number: 3, description: "Start with 3-Digit Numbers and subtract 1-Digit or 2-Digit numbers. For example, 345; 340; 335; 330; ..."),
      Mission(number: 4, description: "Start with a 1-Digit number and multiply by 2 or 3. For example, 3; 6; 12; 24; ..."),
      Mission(number: 5, description: "Start with a 2-Digit number and multiply by 2 or 3. For example, 21; 63; 189; 567; ..."),
      Mission(number: 6, description: "1-Digit or 2-Digit (<=20) squared. For example, 9; 16; 25; 36; ..."),
      Mission(number: 7, description: "Fibonacci series starting with a 1-Digit number (>1). For example, 4; 5; 9; 14; ..."),
      Mission(number: 8, description: "Starts with a 1-Digit number (>1) x 2 + 1. For example, 4; 9; 19; 39; ..."),
      Mission(number: 9, description: "Double a 1-Digit number and the next number is the sum of the digits. For example, 66; 12; 77; 14; ..."),
      Mission(number: 10, description: "Start with a 1-Digit or 2-Digit prime number. For example, 11; 13; 17; 19; ..."),
    ],
  };

  List<Mission> getMissionsForSubject(String subject) {
    return _missions[subject] ?? [];
  }

    void updateMission(String subjectName, int missionNumber, int correctAnswers) {
      final missions = _missions[subjectName];
      if (missions != null && missionNumber <= missions.length) {
        missions[missionNumber - 1].correctAnswers = correctAnswers;
        notifyListeners();  // This tells the UI to rebuild if necessary.
      }
    }
  }