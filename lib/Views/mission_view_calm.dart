import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import provider package

import '../Game views/Calm Bear/calm_bear_game_addition.dart';
import '../Game views/Calm Bear/calm_bear_game_division.dart';
import '../Game views/Calm Bear/calm_bear_game_exponentiation.dart';
import '../Game views/Calm Bear/calm_bear_game_mixed.dart';
import '../Game views/Calm Bear/calm_bear_game_multiplication.dart';
import '../Game views/Calm Bear/calm_bear_game_percentages.dart';
import '../Game views/Calm Bear/calm_bear_game_sequences.dart';
import '../Game views/Calm Bear/calm_bear_game_subtraction.dart';

import 'package:flutter_app/mission_provider.dart'; // Import the MissionsProvider
import 'package:flutter_app/hexagon_progress_painter.dart';

class MissionViewCalm extends StatefulWidget {
  final String subjectName;

  const MissionViewCalm({super.key, required this.subjectName});

  @override
  _MissionViewCalmState createState() => _MissionViewCalmState();
}

class _MissionViewCalmState extends State<MissionViewCalm> {
  late List<Mission> missions; // Use Mission model directly

  @override
  void initState() {
    super.initState();
    // Fetch the missions from the provider based on the subject
    final missionsProvider =
        Provider.of<MissionsProvider>(context, listen: false);
    missions = missionsProvider.getMissionsForSubject(widget.subjectName);
  }

  void updateMission(int missionNumber, int correctAnswers) {
    setState(() {
      // Update the mission with correct answers
      missions[missionNumber - 1].correctAnswers = correctAnswers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final hexWidth = MediaQuery.of(context).size.width /
        (orientation == Orientation.portrait ? 6 : 10);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 50, 50, 50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.subjectName,
          style: GoogleFonts.mali(
            color: const Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: missions.isEmpty
                    ? const Center(
                        child: Text("No missions available for this subject."))
                    : _buildHoneycombGrid(
                        missions, context, hexWidth, orientation),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the honeycomb pattern
  Widget _buildHoneycombGrid(List<Mission> missions, BuildContext context, double hexWidth, Orientation orientation) {
  final columns = orientation == Orientation.portrait ? 2 : 5;
  final rows = (missions.length / columns).ceil();

  return SingleChildScrollView(
    child: HexagonOffsetGrid.oddFlat(
      color: const Color.fromARGB(255, 255, 255, 255),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      columns: columns,
      rows: rows,
      buildTile: (col, row) {
        final missionIndex = row * columns + col;
        if (missionIndex >= missions.length) {
          return HexagonWidgetBuilder(
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Container(), // Empty container
          );
        }

        final mission = missions[missionIndex];
        final progress = (mission.correctAnswers ?? 0) / 15;

        return HexagonWidgetBuilder(
          elevation: 0,
          padding: 4.0,
          cornerRadius: 24.0,
          color: const Color(0xffffee9ae),
          child: GestureDetector(
            onTap: () {
              _navigateToMission(context, widget.subjectName, mission.number);
            },
            child: CustomPaint(
              painter: HexagonProgressPainter(progress: progress),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mission.number.toString(),
                      style: GoogleFonts.mali(
                        color: const Color.fromARGB(255, 50, 50, 50),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${mission.correctAnswers ?? 0} of 15",
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

  Future<void> _navigateToMission(
      BuildContext context, String subjectName, int missionNumber) async {
    int? result;

    if (subjectName == "Addition") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameAddition(
            mode: CalmBearGameAddition.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Subtraction") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameSubtraction(
            mode: CalmBearGameSubtraction.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Multiplication") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameMultiplication(
            mode: CalmBearGameMultiplication.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Division") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameDivision(
            mode: CalmBearGameDivision.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Mixed operations") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameMixed(
            mode: CalmBearGameMixed.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Sequences") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameSequences(
            mode: CalmBearGameSequences.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Exponentiation") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameExponentiation(
            mode: CalmBearGameExponentiation.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Percentages") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGamePercentages(
            mode: CalmBearGamePercentages.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    }
    if (result != null) {
      updateMission(missionNumber, result);
    }
  }
}
