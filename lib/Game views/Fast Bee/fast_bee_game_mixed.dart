import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/mission_provider_fast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastBeeGameMixed extends StatefulWidget {
  // Everything should work
  final String mode;
  final int missionIndex;

  const FastBeeGameMixed({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "1_digit_plus_1_digit_by_1_digit",
    "1_digit_plus_2_digit_by_1_digit",
    "1_digit_times_2_digit_plus_2_digit",
    "2_digit_plus_1_digit_times_1_digit", 
    "3_digit_minus_1_digit_times_1_digit", 
    "2_digit_times_1_digit_minus_1_digit_times_1_digit", 
    "1_digit_times_2_digit_plus_1_digit_times_2_digit",
    "1_digit_times_3_digit_minus_2_digit_times_1_digit",
    "2_digit_plus_2_digit_divided_by_1_digit",
    "3_digit_plus_2_digit_divided_by_1_digit",
  ];

  @override
  State<FastBeeGameMixed> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameMixed> {
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
    String key = "fastMixed operations_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastMixed operations_highestScore_$missionIndex";
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
      case "1_digit_plus_1_digit_by_1_digit":
        int a = random.nextInt(9) + 1;
        int b = random.nextInt(9) + 1;
        int c = random.nextInt(9) + 1;
        currentExpression = "($a + $b) × $c";
        break;
      case "1_digit_plus_2_digit_by_1_digit":
        int a = random.nextInt(9) + 1;
        int b = random.nextInt(90) + 10;
        int c = random.nextInt(9) + 1;
        currentExpression = "($a + $b) × $c";
        break;
      case "1_digit_times_2_digit_plus_2_digit":
        // Updated logic for the 3rd mission
        List<int> allowedNumbers = [1, 2, 5];
        int a = allowedNumbers[
            random.nextInt(allowedNumbers.length)]; // Only 1, 2, or 5
        int b = random.nextInt(90) + 10;
        int c = random.nextInt(90) + 10;
        currentExpression = "$a × ($b + $c)";
        break;
      case "2_digit_plus_1_digit_times_1_digit": // Was the 6th now is the 4th mission
        int a = random.nextInt(90) + 10;
        int b = random.nextInt(9) + 1;
        int c = random.nextInt(9) + 1;
        currentExpression = "($a + $b) × $c";
        break;
      case "3_digit_minus_1_digit_times_1_digit": // was the 7th now is the 5th mission
        int a = random.nextInt(900) + 100;
        int b = random.nextInt(9) + 1;
        int c = random.nextInt(9) + 1;
        currentExpression = "($a - $b) ÷ $c";
        break;
      case "2_digit_times_1_digit_minus_1_digit_times_1_digit": // New 6th mission
        int a = random.nextInt(90) + 10;
        int b = random.nextInt(9) + 1;
        int c = random.nextInt(9) + 1;
        int d = random.nextInt(9) + 1;
        currentExpression = "$a × $b - $c × $d";
        break;
      case "1_digit_times_2_digit_plus_1_digit_times_2_digit": // Was the 4th now is the 7th mission
        int a = random.nextInt(9) + 1;
        int b = random.nextInt(90) + 10;
        int c = random.nextInt(9) + 1;
        int d = random.nextInt(90) + 10;
        currentExpression = "$a × $b + $c × $d";
        break;
      case "1_digit_times_3_digit_minus_2_digit_times_1_digit": // Was the 5th now is th 8th mission
        int a = random.nextInt(9) + 1;
        int b = random.nextInt(900) + 100;
        int c = random.nextInt(90) + 10;
        int d = random.nextInt(9) + 1;
        currentExpression = "$a × $b - $c × $d";
        break;
      case "2_digit_plus_2_digit_divided_by_1_digit":
        int a = random.nextInt(90) + 10;
        int b = random.nextInt(90) + 10;
        int c = random.nextInt(9) + 1;
        while ((a + b) % c != 0) {
          c = random.nextInt(9) + 1;
        }
        currentExpression = "($a + $b) ÷ $c";
        break;
      case "3_digit_plus_2_digit_divided_by_1_digit":
        int a = random.nextInt(900) + 100;
        int b = random.nextInt(90) + 10;
        int c = random.nextInt(9) + 1;
        while ((a + b) % c != 0) {
          c = random.nextInt(9) + 1;
        }
        currentExpression = "($a + $b) ÷ $c";
        break;
      default:
        currentExpression = "Error: Unknown mode";
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
      // Helper to handle operations
      double operate(double a, double b, String op) {
        switch (op) {
          case '+':
            return a + b;
          case '-':
            return a - b;
          case '×':
            return a * b;
          case '÷':
            if (b == 0) throw Exception("Division by zero");
            return a / b; // Use double division
          default:
            throw Exception("Unknown operator");
        }
      }

      // Parsing and evaluating the expression
      final operators = <String>[];
      final operands = <double>[];
      final tokens =
          expression.replaceAll('(', ' ( ').replaceAll(')', ' ) ').split(' ');

      void evaluateTop() {
        double b = operands.removeLast();
        double a = operands.removeLast();
        String op = operators.removeLast();
        operands.add(operate(a, b, op));
      }

      for (var token in tokens) {
        token = token.trim();
        if (token.isEmpty) continue;

        if (double.tryParse(token) != null) {
          // It's a number
          operands.add(double.parse(token));
        } else if (token == '(') {
          // Left parenthesis
          operators.add(token);
        } else if (token == ')') {
          // Right parenthesis
          while (operators.isNotEmpty && operators.last != '(') {
            evaluateTop();
          }
          operators.removeLast(); // Remove the '('
        } else {
          // Operator
          while (operators.isNotEmpty &&
              operators.last != '(' &&
              _precedence(operators.last) >= _precedence(token)) {
            evaluateTop();
          }
          operators.add(token);
        }
      }

      // Evaluate remaining operators
      while (operators.isNotEmpty) {
        evaluateTop();
      }

      return operands.isEmpty ? 0 : operands.last;
    } catch (e) {
      // Return 0 for invalid expressions
      return 0;
    }
  }

// Helper to determine operator precedence
  int _precedence(String operator) {
    switch (operator) {
      case '+':
      case '-':
        return 1;
      case '×':
      case '÷':
        return 2;
      default:
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
                      "Mixed operations", widget.missionIndex + 1, highestScore);

              // Optionally wait a tiny bit to ensure the provider updates
              await Future.delayed(const Duration(milliseconds: 100));

              int nextMissionIndex = widget.missionIndex + 1;
              if (nextMissionIndex < FastBeeGameMixed.missionModes.length) {
                // Remove all game screens and push the next mission
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameMixed(
                      mode: FastBeeGameMixed.missionModes[nextMissionIndex],
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
                      "Mixed operations", widget.missionIndex + 1, highestScore);
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
                    "Mixed operations", widget.missionIndex + 1, highestScore);
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