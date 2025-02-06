import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/mission_provider_fast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastBeeGameSubtraction extends StatefulWidget {
  // I think all expressions work
  final String mode;
  final int missionIndex;

  const FastBeeGameSubtraction({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "sub_2_digit_and_1_digit",
    "sub_2_digit",
    "sub_3_digit_and_1_digit_or_2_digit_without_carry",
    "sub_3_digit_and_1_digit_or_2_digit_with_carry",
    "sub_3_digit_and_2_digit_and_1_digit",
    "sub_3_digit",
    "sub_4_digit_and_2_digit",
    "sub_4_digit_and_3_digit",
    "sub_4_digit",
    "sub_decimals",
  ];

  @override
  State<FastBeeGameSubtraction> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameSubtraction> {
  int sessionScore = 0; // The score for the current session
  int highestScore = 0; // The highest score loaded from storage
  late Timer _timer; // Countdown timer
  late int timeLeft; // Time left for the game
  int preStartTimer = 5; // Countdown before the game starts
  int correctAnswers = 0; // Track correct answers
  int totalQuestionsAnswered = 0; // Track total questions answered
  String currentExpression = ""; // Current math expression
  String userInput = ""; // User's input
  bool gameStarted = false; // Flag to indicate game has started
  bool canSkip = false;
  late TextEditingController _controller; // Persistent controller
  late FocusNode _focusNode; // Focus to autoclick input

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastSubtraction_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastSubtraction_highestScore_$missionIndex";
    return prefs.getInt(key) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    timeLeft =
        widget.missionIndex >= 5 ? 120 : 90; // Adjust time based on mission
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
    _timer.cancel();
    super.dispose();
  }

  // Timer for 5-second pre-game countdown
  void _startPreGameTimer() {
    setState(() {
      sessionScore = 0; // Reset only the session score.
      totalQuestionsAnswered = 1;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted == true) {
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
      if (mounted == true) {
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

  void _generateExpression() {
    final random = Random();

    if (widget.mode == "sub_2_digit_and_1_digit") {
      int a = random.nextInt(90) + 10; // 10 to 99
      int b = random.nextInt(9) + 1; // 1 to 9
      if (b >= a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_2_digit") {
      int a = random.nextInt(90) + 10; // 10 to 99
      int b = random.nextInt(90) + 10; // 10 to 99
      if (b >= a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode ==
        "sub_3_digit_and_1_digit_or_2_digit_without_carry") {
      // No carry-over allowed
      int a = random.nextInt(800) + 100; // 100 to 999
      int b = random.nextInt(99) + 1; // 1 to 99

      // Ensure no carry by adjusting each digit
      int unitsA = a % 10;
      int unitsB =
          random.nextInt(unitsA + 1); // Make sure b's units <= a's units
      b = (b ~/ 10) * 10 + unitsB;

      if (b >= a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_3_digit_and_1_digit_or_2_digit_with_carry") {
      // Carry-over allowed
      int a = random.nextInt(800) + 100; // 100 to 999
      int b = random.nextInt(99) + 1; // 1 to 99
      if (b >= a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_3_digit_and_2_digit_and_1_digit") {
      // Subtract a 2-digit and a 1-digit number from a 3-digit number
      int a = random.nextInt(800) + 100; // 100 to 999
      int b = random.nextInt(90) + 10; // 10 to 99
      int c = random.nextInt(9) + 1; // 1 to 9

      if (b + c >= a) {
        // Ensure a > b + c
        a = b + c + random.nextInt(50) + 1; // Make a sufficiently larger
      }
      currentExpression = "$a - $b - $c";
    } else if (widget.mode == "sub_3_digit") {
      int a = random.nextInt(800) + 100; // 100 to 999
      int b = random.nextInt(800) + 100; // 100 to 999
      if (b >= a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_4_digit_and_2_digit") {
      int a = random.nextInt(9000) + 1000; // 1000 to 9999
      int b = random.nextInt(90) + 10; // 10 to 99
      if (b >= a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_4_digit_and_3_digit") {
      int a = random.nextInt(9000) + 1000; // 1000 to 9999
      int b = random.nextInt(900) + 100; // 100 to 999
      if (b >= a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_4_digit") {
      int a = random.nextInt(9000) + 1000; // 1000 to 9999
      int b = random.nextInt(9000) + 1000; // 1000 to 9999
      if (b >= a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_decimals") {
      // Correct format: xxx.xx - xx.x
      double a = (random.nextInt(90000) + 10000) / 100.0; // 100.00 to 999.99
      double b = (random.nextInt(900) + 100) / 10.0; // 10.0 to 99.9
      if (b >= a) {
        double temp = a;
        a = b;
        b = temp; // Ensure a > b
      }
      currentExpression = "${a.toStringAsFixed(2)} - ${b.toStringAsFixed(1)}";
    }
    if (mounted == true) {
      setState(() {
        userInput = "";
        _controller.text = ""; // Reset input field
        canSkip = false;
        _focusNode.requestFocus();
      });
    }

    // Enable skip after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted == true) {
        setState(() {
          canSkip = true;
        });
      }
    });
  }

  // Evaluate a math expression
  double _evaluateExpression(String expression) {
    try {
      // Split the expression by " - " to handle multiple subtractions
      final parts = expression.split(" - ");
      double result = double.parse(parts[0]);
      // Subtract all subsequent numbers from the result
      for (int i = 1; i < parts.length; i++) {
        result -= double.parse(parts[i]);
      }
      return result;
    } catch (e) {
      return 0.0;
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
          _generateExpression();
          // Update highestScore if needed.
          if (sessionScore > highestScore) {
            highestScore = sessionScore;
          }
        }
      });
    }
  }
      

  // Skip the current question
  void _skipQuestion() {
    if (canSkip) {
      if (mounted == true) {
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
                      "Subtraction", widget.missionIndex + 1, highestScore);

              // Optionally wait a tiny bit to ensure the provider updates
              await Future.delayed(const Duration(milliseconds: 100));

              int nextMissionIndex = widget.missionIndex + 1;
              if (nextMissionIndex < FastBeeGameSubtraction.missionModes.length) {
                // Remove all game screens and push the next mission
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameSubtraction(
                      mode: FastBeeGameSubtraction.missionModes[nextMissionIndex],
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
                      "Subtraction", widget.missionIndex + 1, highestScore);
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
                    "Subtraction", widget.missionIndex + 1, highestScore);
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
                  Text(
                    "Answered: $sessionScore",
                    style: const TextStyle(
                      color: Color(0xffffa400),
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "⏳ $timeLeft seconds",
                    style: const TextStyle(
                      color: Color(0xffffa400),
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentExpression,
                    style: const TextStyle(
                      color: Color(0xffffa400),
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      focusNode: _focusNode,
                      cursorColor: const Color(0xffffa400),
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                      ],
                      onChanged: (value) {
                        if (mounted == true) {
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
                  fontSize: 48,
                ),
              ),
      ),
    );
  }
}
