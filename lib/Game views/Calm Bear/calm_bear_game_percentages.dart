// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Services/mission_provider_calm.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalmBearGamePercentages extends StatefulWidget {
  final String mode;
  final int missionIndex;

  const CalmBearGamePercentages({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "10_percent_of_2_digit_or_3_digit",
    "20_percent_of_2_digit_or_3_digit",
    "50_percent_of_1_digit_2_digit_or_3_digit",
    "20_25_50_percent_of_2_digit_3_digit",
    "2_digit_plus_10_20_25_or_50_percent",
    "2_digit_minus_10_or_50_percent",
    "30_percent_of_2_digit",
    "3_digit_plus_10_20_25_or_50_percent",
    "1_digit_percent_of_2_digit",
    "2_digit_percent_of_2_digit",
  ];

  @override
  State<CalmBearGamePercentages> createState() => _CalmBearGameState();
}

class _CalmBearGameState extends State<CalmBearGamePercentages> {
  int sessionScore = 0; // The score for the current session
  int highestScore = 0; // The highest score loaded from storage
  int correctAnswers = 0; // Track correct answers
  int totalQuestionsAnswered = 1; // Track total questions answered
  String currentExpression = ""; // Current math expression
  String userInput = ""; // User's input
  bool gameStarted = false; // Flag to indicate game has started
  bool showingAnswer = false; // Flag to show correct answer
  late TextEditingController _controller; // Persistent controller
  int preStartTimer = 5; // Pre-start countdown timer
  late Stopwatch _stopwatch; // Stopwatch to track time
  late FocusNode _focusNode;

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "Percentages_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;
    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "Percentages_highestScore_$missionIndex";
    return prefs.getInt(key) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();

    // Load the highest score for this mission at the start.
    _loadHighestScore(widget.missionIndex).then((value) {
      if (mounted) {
        setState(() {
          highestScore = value;
          sessionScore = 0;
        });
      }
    });

    _startPreGameTimer();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Timer for 5-second pre-game countdown.
  void _startPreGameTimer() {
    setState(() {
      sessionScore = 0;
      totalQuestionsAnswered = 1;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (preStartTimer > 0) {
            preStartTimer--;
          } else {
            gameStarted = true;
            _stopwatch = Stopwatch()..start();
            timer.cancel();
            _generateExpression();
          }
        });
      }
    });
  }

  // Generate a random math expression based on the selected mode.
  void _generateExpression() {
    final random = Random();

    if (widget.mode == "10_percent_of_2_digit_or_3_digit") {
      int a = random.nextBool()
          ? random.nextInt(90) + 10
          : random.nextInt(900) + 100;
      currentExpression = "10% of $a";
    } else if (widget.mode == "20_percent_of_2_digit_or_3_digit") {
      int a;
      if (random.nextBool()) {
        a = random.nextInt(90) + 10;
      } else {
        a = random.nextInt(900) + 100;
      }
      currentExpression = "20% of $a";
    } else if (widget.mode == "50_percent_of_1_digit_2_digit_or_3_digit") {
      int a;
      int pick = random.nextInt(3);
      if (pick == 0) {
        a = random.nextInt(9) + 1;
      } else if (pick == 1) {
        a = random.nextInt(90) + 10;
      } else {
        a = random.nextInt(900) + 100;
      }
      currentExpression = "50% of $a";
    } else if (widget.mode ==
        "20_25_50_percent_of_2_digit_3_digit") {
      int a = random.nextBool()
          ? random.nextInt(90) + 10
          : random.nextInt(900) + 100;
      List<int> percentages = [20, 25, 50];
      int percent = percentages[random.nextInt(percentages.length)];
      currentExpression = "$percent% of $a";
    } else if (widget.mode == "2_digit_plus_10_20_25_or_50_percent") {
      int a = random.nextInt(90) + 10;
      List<int> percentages = [10, 20, 25, 50];
      int percent = percentages[random.nextInt(percentages.length)];
      currentExpression = "Increase $a by $percent%";
    } else if (widget.mode == "2_digit_minus_10_or_50_percent") {
      int a = random.nextInt(90) + 10;
      List<int> percentages = [10, 50];
      int percent = percentages[random.nextInt(percentages.length)];
      currentExpression = "Decrease $a by $percent%";
    } else if (widget.mode == "30_percent_of_2_digit") {
      int a = random.nextInt(90) + 10;
      currentExpression = "30% of $a";
    } else if (widget.mode == "3_digit_plus_10_20_25_or_50_percent") {
      int a = random.nextInt(900) + 100;
      List<int> percentages = [10, 20, 25, 50];
      int percent = percentages[random.nextInt(percentages.length)];
      currentExpression = "Increase $a by $percent%";
    } else if (widget.mode == "1_digit_percent_of_2_digit") {
      int a = random.nextInt(90) + 10;
      int percent = random.nextInt(8) + 2;
      currentExpression = "$percent% of $a";
    } else if (widget.mode == "2_digit_percent_of_2_digit") {
      int a = random.nextInt(90) + 10;
      int percent = random.nextInt(90) + 10;
      currentExpression = "$percent% of $a";
    }

    if (mounted) {
      setState(() {
        userInput = "";
        _controller.text = "";
        _focusNode.requestFocus();
        showingAnswer = false;
      });
    }
  }

  // Evaluate the percentage expression.
  double _evaluateExpression(String expression) {
    try {
      // Handle expressions like "20% of 150"
      if (expression.contains(" of ")) {
        final parts = expression.split(" of ");
        double percentage = double.parse(parts[0].replaceAll("%", "").trim());
        double value = double.parse(parts[1].trim());
        return (percentage / 100) * value;
      }
      // Handle expressions that start with "Increase"
      else if (expression.startsWith("Increase")) {
        // Remove the keyword "Increase" and split by " by "
        String temp = expression.replaceFirst("Increase", "").trim();
        List<String> parts = temp.split(" by ");
        if (parts.length < 2) throw Exception("Invalid format for Increase");
        double baseValue = double.parse(parts[0].trim());
        double percentage = double.parse(parts[1].replaceAll("%", "").trim());
        return baseValue + (percentage / 100) * baseValue;
      }
      // Handle expressions that start with "Decrease"
      else if (expression.startsWith("Decrease")) {
        // Remove the keyword "Decrease" and split by " by "
        String temp = expression.replaceFirst("Decrease", "").trim();
        List<String> parts = temp.split(" by ");
        if (parts.length < 2) throw Exception("Invalid format for Decrease");
        double baseValue = double.parse(parts[0].trim());
        double percentage = double.parse(parts[1].replaceAll("%", "").trim());
        return baseValue - (percentage / 100) * baseValue;
      }
    } catch (e) {
      print("Error evaluating expression: $e");
      return 0.0;
    }
    return 0.0;
  }

  void _validateAnswer() {
    final correctAnswer = _evaluateExpression(currentExpression);
    double userAnswer =
        double.tryParse(userInput.replaceAll(",", ".")) ?? double.nan;
    if (mounted) {
      setState(() {
        totalQuestionsAnswered++;
        if ((userAnswer - correctAnswer).abs() < 0.01) {
          sessionScore++;
          if (sessionScore > highestScore) {
            highestScore = sessionScore;
          }
          if (totalQuestionsAnswered == 16) {
            _endGame();
          } else {
            _generateExpression();
          }
        } else {
          showingAnswer = true;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                showingAnswer = false;
                if (totalQuestionsAnswered < 16) {
                  _generateExpression();
                } else {
                  _endGame();
                }
              });
            }
          });
        }
      });
    }
  }

  void _endGame() {
    _stopwatch.stop();
    final elapsedTime = _stopwatch.elapsed;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xffffee9ae),
        title: Text(
          tr('game_screen.mission_over'),
          style: const TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "${tr('game_screen.correct_answers')} $sessionScore\n\n"
          "${tr('game_screen.time_taken')}: ${elapsedTime.inMinutes}m ${elapsedTime.inSeconds % 60}s\n\n"
          "${tr('game_screen.question')}",
          style: const TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveHighestScore(widget.missionIndex, highestScore);
              Provider.of<MissionsProviderCalm>(context, listen: false)
                  .updateMissionProgress(
                      "Percentages", widget.missionIndex + 1, highestScore);
              await Future.delayed(const Duration(milliseconds: 100));
              int nextMissionIndex = widget.missionIndex + 1;
              if (nextMissionIndex <
                  CalmBearGamePercentages.missionModes.length) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalmBearGamePercentages(
                      mode: CalmBearGamePercentages
                          .missionModes[nextMissionIndex],
                      missionIndex: nextMissionIndex,
                    ),
                  ),
                  (Route<dynamic> route) => route.isFirst,
                );
              } else {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: Text(
              tr('game_screen.next_mission'),
              style: const TextStyle(
                fontFamily: 'Mali',
                color: Color.fromARGB(255, 50, 50, 50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _saveHighestScore(widget.missionIndex, highestScore);
              Provider.of<MissionsProviderCalm>(context, listen: false)
                  .updateMissionProgress(
                      "Percentages", widget.missionIndex + 1, highestScore);
              await Future.delayed(const Duration(milliseconds: 100));
              Navigator.pop(context);
              Navigator.pop(context, highestScore);
            },
            child: Text(
              tr('game_screen.back_to_missions'),
              style: const TextStyle(
                fontFamily: 'Mali',
                color: Color.fromARGB(255, 50, 50, 50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Evaluate the current expression and format the result
    final evaluatedResult = _evaluateExpression(currentExpression);
    final resultText = (evaluatedResult % 1 == 0)
        ? evaluatedResult.toInt().toString()
        : evaluatedResult.toStringAsFixed(2);
    // Determine if the answer is wrong
    final bool isWrong = showingAnswer && userInput.trim() != resultText;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _saveHighestScore(widget.missionIndex, highestScore);
            Provider.of<MissionsProviderCalm>(context, listen: false)
                .updateMissionProgress(
                    "Percentages", widget.missionIndex + 1, highestScore);
            await Future.delayed(const Duration(milliseconds: 100));
            Navigator.pop(context, highestScore);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "${tr('game_screen.correct')} $sessionScore",
                style: const TextStyle(
                  fontFamily: 'Mali',
                  color: Color.fromARGB(255, 50, 50, 50),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: gameStarted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$totalQuestionsAnswered${tr("game_screen.of_15")}",
                      style: const TextStyle(
                        fontFamily: 'Mali',
                        color: Color.fromARGB(255, 50, 50, 50),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 30),
                    showingAnswer
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'Mali',
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "$currentExpression = ",
                                      style: const TextStyle(
                                          color: Color(0xffffa400)),
                                    ),
                                    TextSpan(
                                      text: "$resultText ",
                                      style: const TextStyle(
                                          color: Colors.lightGreen),
                                    ),
                                    // Display the users incorrect answer in red with a strike-through
                                    TextSpan(
                                      text: "($userInput)",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (isWrong) // Plays animation if the answer is incorrect
                                Lottie.network(
                                  'https://lottie.host/c2753c92-6b72-47ee-9281-aa75a32c65ba/mfccXVGSGr.json',
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.fill,
                                ),
                            ],
                          )
                        : Text(
                            currentExpression,
                            style: const TextStyle(
                              fontFamily: 'Mali',
                              color: Color(0xffffa400),
                              fontWeight: FontWeight.bold,
                              fontSize: 38,
                            ),
                            textAlign: TextAlign.center,
                          ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        focusNode: _focusNode,
                        cursorColor: const Color(0xffffa400),
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        ],
                        onSubmitted: (value) {
                          if (mounted) {
                            setState(() {
                              userInput = value;
                            });
                          }
                          if (value.isNotEmpty) {
                            _validateAnswer();
                          }
                        },
                        controller: _controller,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffffa400)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffffa400)),
                          ),
                          fillColor: Color(0xffffee9ae),
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              : Text(
                  preStartTimer > 0 ? "$preStartTimer" : tr('game_screen.get_ready'),
                  style: const TextStyle(
                    fontFamily: 'Mali',
                    color: Color(0xffffa400),
                    fontWeight: FontWeight.bold,
                    fontSize: 38,
                  ),
                ),
        ),
      ),
    );
  }
}
