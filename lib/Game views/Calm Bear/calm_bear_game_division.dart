// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/mission_provider_calm.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalmBearGameDivision extends StatefulWidget {
  final String mode;
  final int missionIndex;

  const CalmBearGameDivision({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "div_1_digit",
    "div_1_or_2_digit_by_1_digit_with_decimal_result",
    "div_3_digit_by_1_digit",
    "div_4_digit_by_1_digit",
    "div_2_digit",
    "div_3_digit_by_2_digit",
    "div_3_digit_by_1_digit_by_1_digit",
    "div_decimals_by_1_digit",
    "div_4_digit_by_1_digit_by_1_digit",
    "div_decimals_by_2_digit",
  ];

  @override
  State<CalmBearGameDivision> createState() => _CalmBearGameState();
}

class _CalmBearGameState extends State<CalmBearGameDivision> {
  int sessionScore = 0; // The score for the current session.
  int highestScore = 0; // The highest score loaded from storage.
  int correctAnswers = 0; // Track correct answers
  int totalQuestionsAnswered = 1; // Track total questions answered
  String currentExpression = ""; // Current math expression
  String userInput = ""; // Users input
  bool gameStarted = false; // Flag to indicate game has started
  bool showingAnswer = false; // Flag to show correct answer
  late TextEditingController _controller; // Persistent controller
  int preStartTimer = 5; // Pre-start countdown timer
  late Stopwatch _stopwatch; // Stopwatch to track time
  late FocusNode _focusNode;

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    // Use a subject-specific key:
    String key = "Division_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "Division_highestScore_$missionIndex";
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
          sessionScore = 0; // Always start a new session with 0.
        });
      }
    });

    _startPreGameTimer();
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the FocusNode
    _controller.dispose();
    super.dispose();
  }

  // Timer for 5-second pre game countdown
  void _startPreGameTimer() {
    setState(() {
      sessionScore = 0; // Reset only the session score.
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

  // Generate a random math expression based on the selected mode
  void _generateExpression() {
    final random = Random();

    if (widget.mode == "div_1_digit") {
      int b = random.nextInt(9) + 1;
      int a;
      do {
        a = random.nextBool() ? random.nextInt(90) + 10 : random.nextInt(9) + 1;
      } while (a % b != 0);
      currentExpression = "$a ÷ $b";
    } else if (widget.mode ==
        "div_1_or_2_digit_by_1_digit_with_decimal_result") {
      // Valid one-digit divisor.
      final validBs = [2, 4, 5, 6, 8];
      int b = validBs[random.nextInt(validBs.length)];
      int maxM = (900 / b).floor();
      int m;
      if (b == 5) {
        List<int> possibleMs = [];
        for (int x = 2; x <= maxM; x += 2) {
          if (x % 10 != 0) {
            possibleMs.add(x);
          }
        }
        m = possibleMs[random.nextInt(possibleMs.length)];
      } else {
        List<int> possibleMs = [];
        for (int x = 5; x <= maxM; x += 5) {
          if (x % 10 != 0) {
            possibleMs.add(x);
          }
        }
        m = possibleMs[random.nextInt(possibleMs.length)];
      }
      int a = (m * b) ~/ 10;
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_3_digit_by_1_digit") {
      int b = random.nextInt(9) + 1;
      int a;
      do {
        a = random.nextInt(900) + 100;
      } while (a % b != 0);
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_4_digit_by_1_digit") {
      int b = random.nextInt(9) + 1;
      int a;
      do {
        a = random.nextInt(9000) + 1000;
      } while (a % b != 0);
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_2_digit") {
      int b, a;
      do {
        b = random.nextInt(90) + 10;
        a = random.nextInt(90) + 10;
      } while (a == b || a % b != 0); // Avoid identical numbers
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_3_digit_by_2_digit") {
      int b = random.nextInt(90) + 10;
      int a;
      do {
        a = random.nextInt(900) + 100;
      } while (a % b != 0);
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_3_digit_by_1_digit_by_1_digit") {
      int b = random.nextInt(9) + 1;
      int c = random.nextInt(9) + 1;
      int a;
      do {
        a = random.nextInt(900) + 100;
      } while (a % b != 0 ||
          (a ~/ b) % c != 0); // Ensure no remainders in both steps
      currentExpression = "$a ÷ $b ÷ $c";
    } else if (widget.mode == "div_decimals_by_1_digit") {
      int b = random.nextInt(9) + 1;
      double a;
      do {
        int multiplier = random.nextInt(9000) + 1000; // Multiplier for xxx.xx
        a = multiplier / 100.0;
      } while ((a * 100).toInt() % b != 0); // Ensure result is valid
      currentExpression = "${a.toStringAsFixed(2)} ÷ $b";
    } else if (widget.mode == "div_4_digit_by_1_digit_by_1_digit") {
      int b = random.nextInt(9) + 1;
      int c = random.nextInt(9) + 1;
      int a;
      do {
        a = random.nextInt(9000) + 1000;
      } while (a % b != 0 ||
          (a ~/ b) % c != 0); // Ensure no remainders in both steps
      currentExpression = "$a ÷ $b ÷ $c";
    } else if (widget.mode == "div_decimals_by_2_digit") {
      int b;
      double a;
      do {
        b = random.nextInt(90) + 10;
        int multiplier = random.nextInt(90000) + 10000; // Multiplier for xxx.xx
        a = multiplier / 100.0;
      } while ((a * 100).toInt() % b != 0);
      currentExpression = "${a.toStringAsFixed(2)} ÷ $b";
    }

    setState(() {
      userInput = "";
      _controller.text = ""; // Reset input field
      _focusNode
          .requestFocus(); // Request focus after generating new expression
    });
  }

  // Evaluate a math expression
  double _evaluateExpression(String expression) {
    try {
      final parts = expression.split(" ÷ ");
      if (parts.isEmpty) return 0;

      double result = double.parse(parts[0]);

      // Perform division step-by-step for multiple divisions
      for (int i = 1; i < parts.length; i++) {
        double divisor = double.parse(parts[i]);
        if (divisor == 0) throw ArgumentError("Division by zero");
        result /= divisor;
      }

      return result;
    } catch (e) {
      // Handle parsing errors or division by zero
      return 0;
    }
  }

  // Validate user's answer
  void _validateAnswer() {
    final correctAnswer = _evaluateExpression(currentExpression);
    double userAnswer =
        double.tryParse(userInput.replaceAll(",", ".")) ?? double.nan;
    if (mounted == true) {
      setState(() {
        totalQuestionsAnswered++;

        if ((userAnswer - correctAnswer).abs() < 0.01) {
          sessionScore++; // Increment the session score
          // Update highestScore if needed.
          if (sessionScore > highestScore) {
            highestScore = sessionScore;
          }
          if (totalQuestionsAnswered == 16) {
            _endGame();
          } else {
            _generateExpression();
          }
        } else {
          showingAnswer =
              true; // Show the correct answer for incorrect response
          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              showingAnswer = false;
              if (totalQuestionsAnswered < 16) {
                _generateExpression();
              } else {
                _endGame();
              }
            });
          });
        }
      });
    }
  }

  // End the game
  void _endGame() {
    _stopwatch.stop();
    final elapsedTime = _stopwatch.elapsed;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xffffee9ae),
        title: const Text(
          "Game Over!",
          style: TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Correct answers: $correctAnswers\n\n"
          "Time taken: ${elapsedTime.inMinutes}m ${elapsedTime.inSeconds % 60}s\n\n"
          "Do you want to continue to the next mission or choose a different mission?",
          style: const TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Save the highest score for the finished mission
              await _saveHighestScore(widget.missionIndex, highestScore);

              // Update the provider for the finished mission
              Provider.of<MissionsProviderCalm>(context, listen: false)
                  .updateMissionProgress(
                      "Division", widget.missionIndex + 1, highestScore);

              // Optionally wait a tiny bit to ensure the provider updates
              await Future.delayed(const Duration(milliseconds: 100));

              int nextMissionIndex = widget.missionIndex + 1;
              if (nextMissionIndex < CalmBearGameDivision.missionModes.length) {
                // Remove all game screens and push the next mission
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalmBearGameDivision(
                      mode: CalmBearGameDivision.missionModes[nextMissionIndex],
                      missionIndex: nextMissionIndex,
                    ),
                  ),
                  (Route<dynamic> route) => route.isFirst,
                );
              } else {
                // If no further missions are available, return to the mission view
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: const Text(
              "Next Mission",
              style: TextStyle(
                fontFamily: 'Mali',
                color: Color.fromARGB(255, 50, 50, 50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _saveHighestScore(widget.missionIndex, highestScore);
              // Update the provider
              Provider.of<MissionsProviderCalm>(context, listen: false)
                  .updateMissionProgress(
                      "Division", widget.missionIndex + 1, highestScore);
              await Future.delayed(const Duration(milliseconds: 100));
              Navigator.pop(context);
              Navigator.pop(context, highestScore);
            },
            child: const Text(
              "Back to Missions",
              style: TextStyle(
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

  // Game screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _saveHighestScore(widget.missionIndex, highestScore);
            // Update the provider
            Provider.of<MissionsProviderCalm>(context, listen: false)
                .updateMissionProgress(
                    "Division", widget.missionIndex + 1, highestScore);
            await Future.delayed(const Duration(milliseconds: 100));
            Navigator.pop(context, highestScore);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Correct: $sessionScore",
                style: const TextStyle(
                  fontFamily: 'Mali',
                  color: Color(0xffffa400),
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
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
                      "$totalQuestionsAnswered of 15",
                      style: const TextStyle(
                        fontFamily: 'Mali',
                        color: Color(0xffffa400),
                        fontWeight: FontWeight.bold,
                        fontSize: 38,
                      ),
                    ),
                    const SizedBox(height: 20),
                    showingAnswer
                        ? RichText(
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
                                  style:
                                      const TextStyle(color: Color(0xffffa400)),
                                ),
                                TextSpan(
                                  text: _evaluateExpression(currentExpression)
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.lightGreen,
                                    fontFamily: 'Mali',
                                  ),
                                ),
                                // Display the users incorrect answer in red with a strike
                                TextSpan(
                                  text: "($userInput)",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
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
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
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
                  preStartTimer > 0 ? "$preStartTimer" : "Get Ready!",
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
