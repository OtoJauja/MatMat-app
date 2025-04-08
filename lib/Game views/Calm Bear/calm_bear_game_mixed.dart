// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Services/mission_provider_calm.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalmBearGameMixed extends StatefulWidget {
  final String mode;
  final int missionIndex;

  const CalmBearGameMixed({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "1_digit_plus_1_digit_by_1_digit",
    "1_digit_plus_2_digit_by_1_digit",
    "1_digit_times_2_digit_plus_2_digit",
    "2_digit_plus_1_digit_times_1_digit",
    "2digit_minus_1_digit_times_1_digit",
    "2_digit_times_1_digit_minus_1_digit_times_1_digit",
    "1_digit_times_2_digit_plus_1_digit_times_2_digit",
    "3_digit_times_1_digit_minus_1_digit",
    "2_digit_plus_2_digit_divided_by_1_digit",
    "3_digit_plus_2_digit_divided_by_1_digit",
  ];

  @override
  State<CalmBearGameMixed> createState() => _CalmBearGameState();
}

class _CalmBearGameState extends State<CalmBearGameMixed> {
  int sessionScore = 0; // The score for the current session.
  int highestScore = 0; // The highest score loaded from storage.
  int correctAnswers = 0;
  int totalQuestionsAnswered = 1;
  String currentExpression = "";
  String userInput = "";
  bool gameStarted = false;
  bool showingAnswer = false;
  late TextEditingController _controller;
  int preStartTimer = 5;
  late Stopwatch _stopwatch;
  late FocusNode _focusNode;

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    // Use a subject-specific key:
    String key = "Mixed operations_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "Mixed operations_highestScore_$missionIndex";
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
      case "2digit_minus_1_digit_times_1_digit": // was the 7th now is the 5th mission
        List<int> allowedNumbers = [1, 2, 4, 5];
        int a = random.nextInt(90) + 10;
        int b = random.nextInt(9) + 1;
        int c = allowedNumbers[
            random.nextInt(allowedNumbers.length)];
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
      case "3_digit_times_1_digit_minus_1_digit": // Was the 5th now is th 8th mission
        int a = random.nextInt(900) + 100;
        int b = random.nextInt(9) + 1;
        int c = random.nextInt(9) + 1;
        currentExpression = "$a × $b - $c";
        break;
      case "2_digit_plus_2_digit_divided_by_1_digit":
        int a = random.nextInt(90) + 10;
        int b = random.nextInt(90) + 10;
        int c = random.nextInt(9) + 2;
        while ((a + b) % c != 0) {
          c = random.nextInt(9) + 2;
        }
        currentExpression = "($a + $b) ÷ $c";
        break;
      case "3_digit_plus_2_digit_divided_by_1_digit":
        int a = random.nextInt(900) + 100;
        int b = random.nextInt(90) + 10;
        int c = random.nextInt(9) + 2;
        while ((a + b) % c != 0) {
          c = random.nextInt(9) + 2;
        }
        currentExpression = "($a + $b) ÷ $c";
        break;
      default:
        currentExpression = "Error: Unknown mode";
    }
    if (mounted == true) {
      setState(() {
        userInput = "";
        _controller.text = "";
        _focusNode.requestFocus();
      });
    }
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

    final FocusNode button1FocusNode = FocusNode();
    final FocusNode button2FocusNode = FocusNode();

    void nextMissionAction() async {
      // Save the highest score for the finished mission
      await _saveHighestScore(widget.missionIndex, highestScore);
      // Ensure the userId is passed to update the Firestore
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<MissionsProviderCalm>(context, listen: false)
            .updateMissionProgress(
                "Mixed operations", widget.missionIndex + 1, highestScore,
                userId: userId);
      }
      // Optionally wait a tiny bit to ensure the provider updates
      await Future.delayed(const Duration(milliseconds: 100));
      int nextMissionIndex = widget.missionIndex + 1;
      if (nextMissionIndex < CalmBearGameMixed.missionModes.length) {
        // Remove all game screens and push the next mission
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CalmBearGameMixed(
              mode: CalmBearGameMixed.missionModes[nextMissionIndex],
              missionIndex: nextMissionIndex,
            ),
          ),
          (Route<dynamic> route) => route.isFirst,
        );
      } else {
        // If no further missions are available, return to the mission view
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }

    void backToMissionsAction() async {
      await _saveHighestScore(widget.missionIndex, highestScore);
      // Update the provider
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<MissionsProviderCalm>(context, listen: false)
            .updateMissionProgress(
                "Mixed operations", widget.missionIndex + 1, highestScore,
                userId: userId);
      }
      await Future.delayed(const Duration(milliseconds: 100));
      Navigator.pop(context);
      Navigator.pop(context, highestScore);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final FocusNode rawKeyboardFocusNode = FocusNode();

        return KeyboardListener(
          focusNode: rawKeyboardFocusNode,
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.digit1) {
                button1FocusNode.requestFocus();
              } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
                button2FocusNode.requestFocus();
              } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                if (button1FocusNode.hasFocus) {
                  nextMissionAction();
                } else if (button2FocusNode.hasFocus) {
                  backToMissionsAction();
                }
              }
            }
          },
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              tr('game_screen.mission_over'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "${tr('game_screen.correct_answers')} $sessionScore\n\n"
              "${tr('game_screen.time_taken')}: ${elapsedTime.inMinutes}m ${elapsedTime.inSeconds % 60}s\n\n"
              "${tr('game_screen.question')}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Lottie.asset(
              'assets/animations/lacis3.json',
              height: 150,
              width: 150,
            ),
            actions: [
              Focus(
                focusNode: button1FocusNode,
                child: Builder(
                  builder: (context) {
                    final bool hasFocus = Focus.of(context).hasFocus;
                    return TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return hasFocus ? const Color(0xffffa400) : null;
                          },
                        ),
                      ),
                      onPressed: nextMissionAction,
                      child: Text(
                        tr('game_screen.next_mission'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Focus(
                focusNode: button2FocusNode,
                child: Builder(
                  builder: (context) {
                    final bool hasFocus = Focus.of(context).hasFocus;
                    return TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return hasFocus ? const Color(0xffffa400) : null;
                          },
                        ),
                      ),
                      onPressed: backToMissionsAction,
                      child: Text(
                        tr('game_screen.back_to_missions'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Game screen
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _saveHighestScore(widget.missionIndex, highestScore);
            Provider.of<MissionsProviderCalm>(context, listen: false)
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
                "${tr('game_screen.correct')} $sessionScore",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: gameStarted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$totalQuestionsAnswered ${tr("game_screen.of_15")}",
                      style: const TextStyle(
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
                                    fontSize: 38,
                                    fontFamily: 'Mali',
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
                                Lottie.asset(
                                  'assets/animations/lacis5.json',
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.fill,
                                ),
                            ],
                          )
                        : Text(
                            currentExpression,
                            style: const TextStyle(
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
