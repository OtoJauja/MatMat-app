import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Game views/Fast Bee/fast_bee_game_addition.dart'; // Addition game
import '../Game views/Fast Bee/fast_bee_game_subtraction.dart'; // Subtraction game
import '../Game views/Fast Bee/fast_bee_game_multiplication.dart'; // Multiplication game
import '../Game views/Fast Bee/fast_bee_game_division.dart'; // Division game
import '../Game views/Fast Bee/fast_bee_game_mixed.dart'; // Mixed game
import '../Game views/Fast Bee/fast_bee_game_sequences.dart'; // Sequence game
import '../Game views/Fast Bee/fast_bee_game_exponentiation.dart'; // Exponent game
import '../Game views/Fast Bee/fast_bee_game_percentages.dart'; // Percentage game

import '../mission_progress_fast.dart';

class MissionViewFast extends StatelessWidget {
  final String subjectName;

  const MissionViewFast({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    // Map of subjects and their missions
    final Map<String, List<Map<String, String>>> subjectsAndMissions = {
      "Addition": [
        {"number": "1", "description": "Add 1-Digit Numbers"},
        {"number": "2", "description": "Add 1-Digit and 2-Digit Numbers"},
        {"number": "3", "description": "Add 2-Digit Numbers Without Carrying"},
        {"number": "4", "description": "Add 2-Digit Numbers With Carrying"},
        {"number": "5", "description": "Adding 3-Digit and 2-Digit Numbers"},
        {"number": "6", "description": "Adding 3-Digit and 3-Digit Numbers"},
        {"number": "7", "description": "Adding 4-Digit and 2-Digit Numbers"},
        {"number": "8", "description": "Adding 4-Digit and 3-Digit Numbers"},
        {"number": "9", "description": "Adding 4-Digit and 4-Digit Numbers"},
        {"number": "10", "description": "Addition of Decimals"},
      ],
      "Subtraction": [
        {"number": "1", "description": "Subtracting 2-Digit and 1-Digit Numbers"},
        {"number": "2", "description": "Subtracting 2-Digit Numbers"},
        {"number": "3", "description": "Subtracting 3-Digit or 2-Digit or 1-Digit Numbers Wwithout Carrying"},
        {"number": "4", "description": " Subtracting 3-Digit or 2-Digit or 1-Digit Numbers Wwith Carrying"},
        {"number": "5", "description": "Subtracting 3-Digit and 2-Digit and 1-Digit Numbers"},
        {"number": "6", "description": " Subtracting 3-Digit Numbers"},
        {"number": "7", "description": "Subtracting 4-Digit and 2-Digit Numbers"},
        {"number": "8", "description": "Subtracting 4-Digit and 3-Digit Numbers"},
        {"number": "9", "description": "Subtracting 4-Digit and 4-Digit Numbers"},
        {"number": "10", "description": "Subtraction of Decimals"},
      ],
      "Multiplication": [
        {"number": "1", "description": "Multiplying 1-Digit Numbers"},
        {"number": "2", "description": "Multiplying  1-Digit x 2-Digit Numbers"},
        {"number": "3", "description": "Multiplying  2-Digit x 1-Digit Numbers"},
        {"number": "4", "description": "Multiplying  3-Digit x 1-Digit Numbers or vice versa"},
        {"number": "5", "description": "Multiplying 4-Digit x 1-Digit Numbers or vice versa"},
        {"number": "6", "description": "Multiplying 2-Digit Numbers"},
        {"number": "7", "description": "Multiplying 1-Digit x 1-Digit x 1-Digit Numbers"},
        {"number": "8", "description": "Multiplying 2-Digit x 1-Digit x 1-Digit Numbers"},
        {"number": "9", "description": "Multiplying Decimal Numbers by 1-Digit Numbers"},
        {"number": "10", "description": "Multiplying Decimal Numbers"},
      ],
      "Division": [
        {"number": "1", "description": "Divide 1-Digit Numbers"},
        {"number": "2", "description": "Divide 2-Digit by 1-Digit Numbers"},
        {"number": "3", "description": "Divide 3-Digit by 1-Digit Numbers"},
        {"number": "4", "description": "Divide 4-Digit by 1-Digit Numbers"},
        {"number": "5", "description": "Divide 2-Digit Numbers"},
        {"number": "6", "description": "Divide 3-Digit by 2-Digit Numbers"},
        {"number": "7", "description": "Divide 3-Digit by 1-Digit by 1-Digit Numbers"},
        {"number": "8", "description": "Divide 4-Digit by 1-Digit by 1-Digit Numbers"},
        {"number": "9", "description": "Divide Decimal Numbers by 1-Digit or 2-Digit Numbers"},
        {"number": "10", "description": "Divide Decimal Numbers"},
      ],
      "Mixed operations": [
        {"number": "1", "description": "(1-Digit + 1-Digit) x 1-Digit Numbers"},
        {"number": "2", "description": "(1-Digit + 2-Digit) x 1-Digit Numbers"},
        {"number": "3", "description": "1-Digit x (2-Digit + 2-Digit) Numbers"},
        {"number": "4", "description": "1-Digit x 2-Digit + 1-Digit x 2-Digit Numbers"},
        {"number": "5", "description": "1-Digit x 3-Digit - 2-Digit x 1-Digit Numbers"},
        {"number": "6", "description": "2-Digit x 2-Digit - 2-Digit x 1-Digit Numbers"},
        {"number": "7", "description": "(1-Digit + 1-Digit) x (1-Digit + 1-Digit) Numbers"},
        {"number": "8", "description": "(2-Digit - 1-Digit) : 1-Digit Numbers"},
        {"number": "9", "description": "(3-Digit + 2-Digit) : 1-Digit Numbers"},
        {"number": "10", "description": "2-Digit x 1-Digit + 2-Digit x 2-Digit Numbers"},
      ],
      "Exponentiation": [
        {"number": "1", "description": "1-Digit Squared"},
        {"number": "2", "description": "2-Digit Squared"},
        {"number": "3", "description": "1-Digit Cubed"},
        {"number": "4", "description": "1-Digit Squared + 1-Digit Squared"},
        {"number": "5", "description": "1-Digit Cubed - 1-Digit Squared"},
        {"number": "6", "description": "Square root of 1-Digit, 2-Digit or 3-Digit Numbers"},
        {"number": "7", "description": "Cubic root of 1-Digit, 2-Digit or 3-Digit Numbers"},
        {"number": "8", "description": "Square root of 1-Digit or 2-Digit + 1-Digit Squared"},
        {"number": "9", "description": "Square root of 2-Digit × square root of 2-Digit Numbers"},
        {"number": "10", "description": "Square of 2-Digits Divided by the square root of 2-Digits or 3-Digits"},
      ],
      "Percentages": [
        {"number": "1", "description": "10% of 2-Digit or 3-Digit Numbers"},
        {"number": "2", "description": "20% of 2-Digit or 3-Digit (divisible by 5 without remainder)"},
        {"number": "3", "description": "50% of 1-Digit, 2-Digit or 3-Digit"},
        {"number": "4", "description": "20%, 25% or 50% of 2-Digit, 3-Digit or 4-Digit"},
        {"number": "5", "description": "2-Digit + 10%, 20%, 25% or 50%"},
        {"number": "6", "description": "2-Digit - 10%, 20%, 25% or 50%"},
        {"number": "7", "description": "30% of 3-Digit"},
        {"number": "8", "description": "3-Digit + 10%, 20%, 25% or 50%"},
        {"number": "9", "description": "1-Digit % of 2-Digit Numbers"},
        {"number": "10", "description": "2-Digit % of 2-Digit numbers"},
      ],
      "Sequences": [
        {"number": "1", "description": "Start with 1; 2; 3 or 4 and add 1-Digit. For example, 4; 11; 18; 25; ..."},
        {"number": "2", "description": "Start with 2-Digit numbers and add 1-Digit numbers. For example, 23; 28; 33; 38; ..."},
        {"number": "3", "description": "Start with 3-Digit Numbers and subtract 1-Digit or 2 Digit numbers. For example, 345; 340; 335; 330; ..."},
        {"number": "4", "description": "Start with a 1-Digit number and multiply by 2 or 3. For example, 3; 6; 12; 24; ..."},
        {"number": "5", "description": "Start with a 2-Digit number and multiply by 2 or 3. For example, 21; 63; 189; 56; ..."},
        {"number": "6", "description": "1-Digit or 2-Digit (<=20) squared. For example, 9; 16; 25; 36; ..."},
        {"number": "7", "description": "Fibonacci series starting with a 1-Digit number (>1). For example, 4; 5; 9; 14; ..."},
        {"number": "8", "description": "Starts with a 1-Digit number (>1) x 2 +1. For example, 4; 9; 19; 39; ..."},
        {"number": "9", "description": "Double a 1-Digit number and the next number is the sum of the digits. For example, 66; 12; 77; 14; ..."},
        {"number": "10", "description": "Start with a 1-Digit or 2-Digit prime number. For example, 11; 13; 17; 19; ..."},
      ],
    };

    final List<Map<String, String>> missions = subjectsAndMissions[subjectName] ?? [];
    final orientation = MediaQuery.of(context).orientation;
    final hexWidth = MediaQuery.of(context).size.width / (orientation == Orientation.portrait ? 6 : 10);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffa400),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          subjectName,
          style: GoogleFonts.mali(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xffffa400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: missions.isEmpty
                    ? const Center(child: Text("No missions available for this subject."))
                    : _buildHoneycombGrid(missions, context, hexWidth, orientation),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bulds the honeycomb pattern
  Widget _buildHoneycombGrid(List<Map<String, String>> missions, BuildContext context, double hexWidth, Orientation orientation) {
  final validMissions = missions.where((mission) => mission["description"] != null && mission["number"] != null).toList();

  final columns = orientation == Orientation.portrait ? 2 : 5;
  final rows = (validMissions.length / columns).ceil();

  return SingleChildScrollView(
    child: HexagonOffsetGrid.oddFlat(
      color: const Color(0xffffa400),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      columns: columns,
      rows: rows,
      buildTile: (col, row) {
        final missionIndex = row * columns + col;
        if (missionIndex >= validMissions.length) {
          return HexagonWidgetBuilder(
            color: const Color(0xffffa400),
            child: Container(), // Empty container
          );
        }

        final mission = validMissions[missionIndex];
        final missionProgress = MissionProgress.getMissionProgress(mission["description"]!);

        return HexagonWidgetBuilder(
          elevation: 0,
          padding: 4.0,
          cornerRadius: 24.0,
          color: const Color(0xffffee9ae),
          child: GestureDetector(
            onTap: () {
              final numberString = mission["number"];
              final description = mission["description"];
              if (numberString != null && description != null) {
                final missionNumber = int.parse(numberString);
                _navigateToMission(context, subjectName, missionNumber);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffee9ae),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mission["number"]!,
                      style: GoogleFonts.mali(
                        color: const Color.fromARGB(255, 50, 50, 50),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$missionProgress of 15",
                      style: GoogleFonts.mali(
                        color: const Color.fromARGB(255, 50, 50, 50),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

  void _navigateToMission(
      BuildContext context, String subjectName, int missionNumber) {
    // Navigation logic based on subject and mission number
    if (subjectName == "Addition") {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameAddition(
            mode: FastBeeGameAddition.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Subtraction") {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameSubtraction(
            mode: FastBeeGameSubtraction.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Multiplication") {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameMultiplication(
            mode: FastBeeGameMultiplication.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Division") {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameDivision(
            mode: FastBeeGameDivision.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Mixed operations") {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameMixed(
            mode: FastBeeGameMixed.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Sequences") {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameSequences(
            mode: FastBeeGameSequences.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Exponentiation") {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameExponentiation(
            mode: FastBeeGameExponentiation.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Percentages") {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGamePercentages(
            mode: FastBeeGamePercentages.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    }
  }
}