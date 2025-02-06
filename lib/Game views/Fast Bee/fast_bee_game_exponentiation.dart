import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/mission_provider_fast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastBeeGameExponentiation extends StatefulWidget {
  // The expressions should work correctly
  final String mode;
  final int missionIndex;

  const FastBeeGameExponentiation({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "1_digit_squared",
    "2_digit_squared",
    "1_digit_cubed",
    "1_digit_squared_plus_1_digit_squared",
    "1_digit_cubed_minus_1_digit_squared",
    "square_root_of_1_digit_2_digit_3_digit",
    "cubic_root_of_1_digit_2_digit_3_digit",
    "square_root_of_1_digit_or_2_digit_plus_1_digit",
    "square_root_of_2_digit_times_square_root_of_2_digit",
    "square_root_of_2_digit_divided_square_root_of_2_digit_or_3_digit",
  ];

  @override
  State<FastBeeGameExponentiation> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameExponentiation> {
  int sessionScore = 0; // The score for the current session
  int highestScore = 0; // The highest score loaded from storage
  late Timer _timer; // Countdown timer
  int timeLeft = 90; // 90 seconds to complete
  int preStartTimer = 5; // Countdown before the game starts
  int correctAnswers = 0; // Track correct answers
  int totalQuestionsAnswered = 1; // Track total questions answered
  String currentExpression = ""; // Current math expression
  String userInput = ""; // User's input
  List<String> mistakes = []; // List of incorrect expressions
  bool gameStarted = false; // Flag to indicate game has started
  bool canSkip = false; // Sets the skip button to false
  late TextEditingController _controller; // Persistent controller
  late FocusNode _focusNode; // Focus to autoclick input

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastExponentiation_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastExponentiation_highestScore_$missionIndex";
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

  // Generate a random math expression based on the selected mode
  void _generateExpression() {
    final random = Random();

    switch (widget.mode) {
      case "1_digit_squared":
        int a = random.nextInt(9) + 1;
        currentExpression = "$a²";
        break;
      case "2_digit_squared":
        int a = random.nextInt(90) + 10;
        currentExpression = "$a²";
        break;
      case "1_digit_cubed":
        int a = random.nextInt(9) + 1;
        currentExpression = "$a³";
        break;
      case "1_digit_squared_plus_1_digit_squared":
        int a = random.nextInt(9) + 1;
        int b = random.nextInt(9) + 1;
        currentExpression = "$a² + $b²";
        break;
      case "1_digit_cubed_minus_1_digit_squared":
        int a = random.nextInt(9) + 1;
        int b = random.nextInt(9) + 1;
        currentExpression = "$a³ - $b²";
        break;
      case "square_root_of_1_digit_2_digit_3_digit":
        List<int> perfectSquares = [for (int i = 2; i <= 31; i += 2) i * i];
        int a = perfectSquares[random.nextInt(perfectSquares.length)];
        currentExpression = "√$a";
        break;
      case "cubic_root_of_1_digit_2_digit_3_digit":
        int a = [
          pow(1, 3).toInt(),
          pow(2, 3).toInt(),
          pow(3, 3).toInt(),
          pow(4, 3).toInt(),
          pow(5, 3).toInt(),
        ][random.nextInt(5)];
        currentExpression = "∛$a";
        break;
      case "square_root_of_1_digit_or_2_digit_plus_1_digit":
        List<int> perfectSquares1 = [
          for (int i = 1; i <= 9; i++) i * i // 1² to 9²
        ];
        int a = perfectSquares1[random.nextInt(perfectSquares1.length)];
        int b = random.nextInt(9) + 1; // 1-9
        currentExpression = "√$a + $b";
        break;
      case "square_root_of_2_digit_times_square_root_of_2_digit":
        List<int> perfectSquares2Digit = [
          for (int i = 4; i <= 9; i++) i * i // 16, 36, 64, 81
        ];
        int a =
            perfectSquares2Digit[random.nextInt(perfectSquares2Digit.length)];
        int b =
            perfectSquares2Digit[random.nextInt(perfectSquares2Digit.length)];
        currentExpression = "√$a * √$b";
        break;
      case "square_root_of_2_digit_divided_square_root_of_2_digit_or_3_digit":
        List<int> perfectSquares2DigitOr3Digit = [
          for (int i = 4; i <= 31; i++) i * i // Perfect squares from 4² to 31²
        ];

        int a, b;
        do {
          a = perfectSquares2DigitOr3Digit[
              random.nextInt(perfectSquares2DigitOr3Digit.length)];
          b = perfectSquares2DigitOr3Digit[
              random.nextInt(perfectSquares2DigitOr3Digit.length)];
        } while (
            sqrt(a) % sqrt(b) != 0 || a == b); // Ensure divisibility and a != b

        currentExpression = "√$a / √$b";
        break;
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
  int _evaluateExpression(String expression) {
    try {
      // Handle square roots
      if (expression.contains("√")) {
        // Parse square root expressions
        if (expression.contains("*")) {
          var parts = expression.split("*");
          int left = _evaluateExpression(parts[0].trim());
          int right = _evaluateExpression(parts[1].trim());
          return left * right;
        } else if (expression.contains("/")) {
          var parts = expression.split("/");
          int left = _evaluateExpression(parts[0].trim());
          int right = _evaluateExpression(parts[1].trim());
          return left ~/ right;
        } else if (expression.contains("+")) {
          var parts = expression.split("+");
          int left = _evaluateExpression(parts[0].trim());
          int right = _evaluateExpression(parts[1].trim());
          return left + right;
        } else if (expression.contains("-")) {
          var parts = expression.split("-");
          int left = _evaluateExpression(parts[0].trim());
          int right = _evaluateExpression(parts[1].trim());
          return left - right;
        } else {
          // Simple square root
          String baseStr = expression.replaceAll(RegExp(r"[√ ]"), "");
          int base = int.parse(baseStr);
          return sqrt(base).toInt();
        }
      }
      // Handle cubic roots
      if (expression.contains("∛")) {
        String baseStr = expression.replaceAll(RegExp(r"[∛ ]"), "");
        int base = int.parse(baseStr);
        return pow(base, 1 / 3).round();
      }
      // Handle squares
      if (expression.contains("²")) {
        int base = int.parse(expression.replaceAll("²", ""));
        return pow(base, 2).toInt();
      }
      // Handle cubes
      if (expression.contains("³")) {
        int base = int.parse(expression.replaceAll("³", ""));
        return pow(base, 3).toInt();
      }
      // Handle addition
      if (expression.contains("+")) {
        var parts = expression.split("+");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left + right;
      }
      // Handle subtraction
      if (expression.contains("-")) {
        var parts = expression.split("-");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left - right;
      }
      // Handle multiplication
      if (expression.contains("*")) {
        var parts = expression.split("*");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left * right;
      }
      // Handle division
      if (expression.contains("/")) {
        var parts = expression.split("/");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left ~/ right;
      }
    } catch (e) {
      return 0; // Return 0 if there's an error
    }

    // If the expression is a plain number
    return int.tryParse(expression) ?? 0;
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
                      "Exponentiation", widget.missionIndex + 1, highestScore);

              // Optionally wait a tiny bit to ensure the provider updates
              await Future.delayed(const Duration(milliseconds: 100));

              int nextMissionIndex = widget.missionIndex + 1;
              if (nextMissionIndex < FastBeeGameExponentiation.missionModes.length) {
                // Remove all game screens and push the next mission
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameExponentiation(
                      mode: FastBeeGameExponentiation.missionModes[nextMissionIndex],
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
                      "Exponentiation", widget.missionIndex + 1, highestScore);
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
                    "Exponentiation", widget.missionIndex + 1, highestScore);
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
