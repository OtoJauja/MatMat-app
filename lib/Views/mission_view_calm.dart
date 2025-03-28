import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Game views/Calm Bear/calm_bear_game_addition.dart';
import '../Game views/Calm Bear/calm_bear_game_division.dart';
import '../Game views/Calm Bear/calm_bear_game_exponentiation.dart';
import '../Game views/Calm Bear/calm_bear_game_mixed.dart';
import '../Game views/Calm Bear/calm_bear_game_multiplication.dart';
import '../Game views/Calm Bear/calm_bear_game_percentages.dart';
import '../Game views/Calm Bear/calm_bear_game_sequences.dart';
import '../Game views/Calm Bear/calm_bear_game_subtraction.dart';

import 'package:flutter_app/Services/mission_provider_calm.dart';
import 'package:flutter_app/hexagon_progress_painter.dart';

class MissionViewCalm extends StatefulWidget {
  final String subjectName;

  const MissionViewCalm({super.key, required this.subjectName});

  @override
  _MissionViewCalmState createState() => _MissionViewCalmState();
}

class _MissionViewCalmState extends State<MissionViewCalm> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    Provider.of<MissionsProviderCalm>(context, listen: false)
        .loadProgressFromFirestore(userId, widget.subjectName);
  }

  void updateMission(int missionNumber, int newScore) {
    final missionsProvider =
        Provider.of<MissionsProviderCalm>(context, listen: false);
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
          // Use the localized subject title for display
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
              Expanded(
                child: Consumer<MissionsProviderCalm>(
                  builder: (context, missionsProvider, child) {
                    List<Mission> missions =
                        missionsProvider.getMissionsForSubject(widget.subjectName);
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
                        : _buildHoneycombGrid(missions, context, hexWidth, orientation);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              child: Container(),
            );
          }

          final mission = missions[missionIndex];
          final progress = (mission.correctAnswers) / 15;

          return HexagonWidgetBuilder(
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
                        "${mission.correctAnswers} ${tr('mission.of_15')}",
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

  Future<void> _navigateToMission(BuildContext context, String subjectName, int missionNumber) async {
    int? result;

    if (subjectName.toLowerCase() == "addition".toLowerCase()) {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameAddition(
            mode: CalmBearGameAddition.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName.toLowerCase() == "subtraction".toLowerCase()) {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameSubtraction(
            mode: CalmBearGameSubtraction.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName.toLowerCase() == "multiplication".toLowerCase()) {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameMultiplication(
            mode: CalmBearGameMultiplication.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName.toLowerCase() == "division".toLowerCase()) {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameDivision(
            mode: CalmBearGameDivision.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName.toLowerCase() == "mixed operations".toLowerCase() ||
        subjectName.toLowerCase() == "mixed_operations".toLowerCase()) {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameMixed(
            mode: CalmBearGameMixed.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName.toLowerCase() == "sequences".toLowerCase()) {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameSequences(
            mode: CalmBearGameSequences.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName.toLowerCase() == "exponentiation".toLowerCase()) {
      result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CalmBearGameExponentiation(
            mode: CalmBearGameExponentiation.missionModes[missionNumber - 1],
            missionIndex: missionNumber - 1,
          ),
        ),
      );
    } else if (subjectName.toLowerCase() == "percentages".toLowerCase()) {
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