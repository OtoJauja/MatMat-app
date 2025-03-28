import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Game views/Fast Bee/fast_bee_game_addition.dart'; // Addition game
import '../Game views/Fast Bee/fast_bee_game_subtraction.dart'; // Subtraction game
import '../Game views/Fast Bee/fast_bee_game_multiplication.dart'; // Multiplication game
import '../Game views/Fast Bee/fast_bee_game_division.dart'; // Division game
import '../Game views/Fast Bee/fast_bee_game_mixed.dart'; // Mixed game
import '../Game views/Fast Bee/fast_bee_game_sequences.dart'; // Sequence game
import '../Game views/Fast Bee/fast_bee_game_exponentiation.dart'; // Exponent game
import '../Game views/Fast Bee/fast_bee_game_percentages.dart'; // Percentage game

import 'package:flutter_app/Services/mission_provider_fast.dart'; // Import the Missions for Fast bee
import 'package:flutter_app/hexagon_progress_painter.dart'; // Import hexagon progress painter

class MissionViewFast extends StatefulWidget {
  final String subjectName;

  const MissionViewFast({super.key, required this.subjectName});

  @override
  _MissionViewFastState createState() => _MissionViewFastState();
}

class _MissionViewFastState extends State<MissionViewFast> {
   @override
  void initState() {
    super.initState();
    // Get the current users UID from FirebaseAuth
    final userId = FirebaseAuth.instance.currentUser!.uid;
    // Load progress from Firestore for the given subject
    Provider.of<MissionsProviderFast>(context, listen: false)
        .loadProgressFromFirestore(userId, widget.subjectName);
  }

  void updateMission(int missionNumber, int newScore) {
    final missionsProvider =
        Provider.of<MissionsProviderFast>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    missionsProvider.updateMissionProgress(
      widget.subjectName,
      missionNumber,
      newScore,
      userId: userId,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final hexWidth = MediaQuery.of(context).size.width /
        (orientation == Orientation.portrait ? 6 : 10);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('subject_view.${widget.subjectName}'),
          style: const TextStyle(
            fontFamily: 'Mali',
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use Consumer to rebuild when the missions update
              Expanded(
                child: Consumer<MissionsProviderFast>(
                  builder: (context, missionsProvider, child) {
                    List<Mission> missions = missionsProvider
                        .getMissionsForSubject(widget.subjectName);
                    return missions.isEmpty
                        ? Center(
                            child: Text(
                              tr('mission.no_missions'),
                              style: const TextStyle(
                                fontFamily: 'Mali',
                                fontSize: 18,
                                color: Color.fromARGB(255, 50, 50, 50),
                              ),
                            ),
                          )
                        : _buildHoneycombGrid(
                            missions, context, hexWidth, orientation);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the honeycomb pattern
  Widget _buildHoneycombGrid(List<Mission> missions, BuildContext context,
      double hexWidth, Orientation orientation) {
    final columns = orientation == Orientation.portrait ? 2 : 5;
    final rows = (missions.length / columns).ceil();

    return SingleChildScrollView(
      child: HexagonOffsetGrid.oddFlat(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        columns: columns,
        rows: rows,
        buildTile: (col, row) {
          final missionIndex = row * columns + col;
          if (missionIndex >= missions.length) {
            return HexagonWidgetBuilder(
              color: Theme.of(context).colorScheme.surface,
              child: Container(), // Empty container
            );
          }

          final mission = missions[missionIndex];
          final progress = (mission.correctAnswers) / 15;

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
                        style: const TextStyle(
                          fontFamily: 'Mali',
                          color: Color.fromARGB(255, 50, 50, 50),
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${tr("mission.highest")} ${mission.correctAnswers}",
                        style: const TextStyle(
                          fontFamily: 'Mali',
                          color: Color.fromARGB(255, 50, 50, 50),
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
          builder: (context) => FastBeeGameAddition(
            mode: FastBeeGameAddition.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Subtraction") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameSubtraction(
            mode: FastBeeGameSubtraction.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Multiplication") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameMultiplication(
            mode: FastBeeGameMultiplication.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Division") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameDivision(
            mode: FastBeeGameDivision.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Mixed operations") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameMixed(
            mode: FastBeeGameMixed.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Sequences") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameSequences(
            mode: FastBeeGameSequences.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Exponentiation") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGameExponentiation(
            mode: FastBeeGameExponentiation.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName == "Percentages") {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => FastBeeGamePercentages(
            mode: FastBeeGamePercentages.missionModes[missionNumber - 1],
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
