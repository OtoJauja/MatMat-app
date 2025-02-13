// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/mission_provider_fast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastBeeGameDivision extends StatefulWidget {
  // everything should work
  final String mode;
  final int missionIndex;

  const FastBeeGameDivision({
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
  State<FastBeeGameDivision> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameDivision> {
  int sessionScore = 0; // The score for the current session
  int highestScore = 0; // The highest score loaded from storage
  late Timer _timer; // Countdown timer for the game
  late int timeLeft; // Time left for the game
  int preStartTimer = 5; // Countdown before the game starts
  int correctAnswers = 0; // Track correct answers
  int totalQuestionsAnswered = 0; // Track total questions answered
  String currentExpression = ""; // Current math expression
  String userInput = ""; // User's input
  bool gameStarted = false; // Flag to indicate game has started
  bool canSkip = false;
  late TextEditingController _controller; // Persistent controller
  late FocusNode _focusNode; // Focus to auto-click input

  // Timer for the skip functionality
  Timer? _skipTimer;

  // Input field fill color variable
  Color _inputFillColor = const Color(0xffffee9ae);

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastDivision_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastDivision_highestScore_$missionIndex";
    return prefs.getInt(key) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    timeLeft = widget.missionIndex >= 5 ? 120 : 90; // Adjust time based on mission - 1-5 = 60s / 6-10 = 120
    _focusNode = FocusNode();
    _controller = TextEditingController();
    // Load the highest score for this mission at the start
    _loadHighestScore(widget.missionIndex).then((value) {
      if (mounted) {
        setState(() {
          highestScore = value;
          sessionScore = 0; // Always start a new session with 0
        });
      }
    });
    _startPreGameTimer();
  }

  @override
  void dispose() {
    _skipTimer?.cancel(); // Cancel the skip timer if it's active
    _focusNode.dispose(); // Dispose of the FocusNode
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Timer for 5-second pre-game countdown
  void _startPreGameTimer() {
    setState(() {
      sessionScore = 0; // Reset only the session score
      totalQuestionsAnswered = 1;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (preStartTimer > 0) {
            preStartTimer--;
          } else {
            gameStarted = true;
            timer.cancel();
            _generateExpression();
            _startGameTimer();
          }
        });
      }
    });
  }

  // Main game timer
  void _startGameTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            timer.cancel();
            _endGame();
          }
        });
      }
    });
  }

  // Generate a random math expression based on the selected mode
  void _generateExpression() {
    final random = Random();
    _skipTimer?.cancel();
    if (widget.mode == "div_1_digit") {
      int b = random.nextInt(9) + 1;
      int a;
      do {
        a = random.nextBool() ? random.nextInt(90) + 10 : random.nextInt(9) + 1;
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a ÷ $b";
    } else if (widget.mode ==
        "div_1_or_2_digit_by_1_digit_with_decimal_result") {
      int b = random.nextInt(9) + 1; 
      int a;
      do {
        a = random.nextInt(90) + 1; 
      } while (a % b == 0); // Ensure result is decimal
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_3_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = random.nextInt(900) + 100; 
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_4_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = random.nextInt(9000) + 1000; 
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_2_digit") {
      int b, a;
      do {
        b = random.nextInt(90) + 10; // Divisor
        a = random.nextInt(90) + 10; // Numerator
      } while (a == b || a % b != 0); // Avoid identical numbers
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_3_digit_by_2_digit") {
      int b = random.nextInt(90) + 10; // Divisor
      int a;
      do {
        a = random.nextInt(900) + 100; 
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_3_digit_by_1_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // First divisor
      int c = random.nextInt(9) + 1; // Second divisor
      int a;
      do {
        a = random.nextInt(900) + 100; 
      } while (a % b != 0 ||
          (a ~/ b) % c != 0); // Ensure no remainders in both steps
      currentExpression = "$a ÷ $b ÷ $c";
    } else if (widget.mode == "div_decimals_by_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      double a;
      do {
        int multiplier = random.nextInt(9000) + 1000; // Multiplier for xxx.xx
        a = multiplier / 100.0;
      } while ((a * 100).toInt() % b != 0); // Ensure result is valid
      currentExpression = "${a.toStringAsFixed(2)} ÷ $b";
    } else if (widget.mode == "div_4_digit_by_1_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // First divisor
      int c = random.nextInt(9) + 1; // Second divisor
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
        b = random.nextInt(90) + 10; // Divisor
        int multiplier = random.nextInt(90000) + 10000; // Multiplier for xxx.xx
        a = multiplier / 100.0;
      } while ((a * 100).toInt() % b != 0); // Ensure result is valid
      currentExpression = "${a.toStringAsFixed(2)} ÷ $b";
    }
    if (mounted) {
      setState(() {
        userInput = "";
        _controller.text = "";
        canSkip = false;
        // Reset the fill color back to default
        _inputFillColor = const Color(0xffffee9ae);
        _focusNode.requestFocus();
      });
    }

    // Start a new timer to enable skip after 5 seconds
    _skipTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          canSkip = true;
        });
      }
    });
  }

  // Evaluate a math expression
  double _evaluateExpression(String expression) {
    try {
      final parts = expression.split(" ÷ ");
      if (parts.isEmpty) return 0;

      // Parse the first number
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
    if (mounted) {
      // If the answer is correct
      if ((userAnswer - correctAnswer).abs() < 0.01) {
        setState(() {
          sessionScore++; // Increment the session score
          // Update highestScore if needed.
          if (sessionScore > highestScore) {
            highestScore = sessionScore;
          }
          // Change input field color to green as a confirmation
          _inputFillColor = Colors.green.shade200;
        });
        // Wait for 1 second before proceeding to the next expression
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              totalQuestionsAnswered++;
              _generateExpression();
              _inputFillColor = const Color(0xffffee9ae);
            });
          }
        });
      }
    }
  }
      

  // Skip the current question
  void _skipQuestion() {
    if (canSkip) {
      // Cancel the current skip timer so it doesn't override new state
      _skipTimer?.cancel();
      if (mounted) {
        setState(() {
          _generateExpression();
          canSkip = false;
        });
      }
    }
  }

  // End the game
  void _endGame() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xffffee9ae),
        title: const Text(
          "Time's Up!",
          style: TextStyle(
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Correct answers: $sessionScore\n\n"
          "Do you want to continue to the next mission or choose a different mission?",
          style: const TextStyle(
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
              Provider.of<MissionsProviderFast>(context, listen: false)
                  .updateMissionProgress(
                      "Division", widget.missionIndex + 1, highestScore);

              // Optionally wait a tiny bit to ensure the provider updates
              await Future.delayed(const Duration(milliseconds: 100));

              int nextMissionIndex = widget.missionIndex + 1;
              if (nextMissionIndex < FastBeeGameDivision.missionModes.length) {
                // Remove all game screens and push the next mission
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameDivision(
                      mode: FastBeeGameDivision.missionModes[nextMissionIndex],
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
              Provider.of<MissionsProviderFast>(context, listen: false)
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
            Provider.of<MissionsProviderFast>(context, listen: false)
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
      backgroundColor: Colors.white,
      body: Center(
        child: gameStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "⏳ $timeLeft seconds",
                    style: const TextStyle(
                      color: Color(0xffffa400),
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentExpression,
                    style: const TextStyle(
                      color: Color(0xffffa400),
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      focusNode: _focusNode,
                      cursorColor: const Color(0xffffa400),
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                      onChanged: (value) {
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
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffffa400)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffffa400)),
                        ),
                        fillColor: _inputFillColor,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: canSkip ? _skipQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffffee9ae),
                    ),
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Color.fromARGB(255, 50, 50, 50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                preStartTimer > 0 ? "$preStartTimer" : "Get Ready!",
                style: const TextStyle(
                  color: Color(0xffffa400),
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
      ),
    );
  }
}

