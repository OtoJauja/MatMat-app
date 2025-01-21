import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    "1_digit_times_2_digit_plus_1_digit_times_2_digit",
    "1_digit_times_3_digit_minus_2_digit_times_1_digit",
    "2_digit_times_2_digit_minus_2_digit_times_1_digit",
    "1_digit_plus_1_digit_times_1_digit_plus_1_digit",
    "2_digit_minus_1_digit_divided_by_1_digit",
    "3_digit_plus_2_digit_divided_by_1_digit",
    "2_digit_times_1_digit_plus_2_digit_times_2_digit",
  ];

  @override
  State<CalmBearGameMixed> createState() => _CalmBearGameState();
}

class _CalmBearGameState extends State<CalmBearGameMixed> {
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

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _startPreGameTimer();
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the FocusNode
    _controller.dispose();
    super.dispose();
  }

  // Timer for 5-second pre-game countdown
  void _startPreGameTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (preStartTimer > 0) {
          preStartTimer--;
        } else {
          gameStarted = true;
          _stopwatch = Stopwatch()..start(); // Start the stopwatch
          timer.cancel();
          _generateExpression();
        }
      });
    });
  }

  // Generate a random math expression based on the selected mode
  void _generateExpression() {
    final random = Random();

    switch (widget.mode) {
      case "1_digit_plus_1_digit_by_1_digit":
        int a = random.nextInt(9) + 1; // 1-digit
        int b = random.nextInt(9) + 1; // 1-digit
        int c = random.nextInt(9) + 1; // 1-digit
        currentExpression = "($a + $b) × $c";
        break;
      case "1_digit_plus_2_digit_by_1_digit":
        int a = random.nextInt(9) + 1; // 1-digit
        int b = random.nextInt(90) + 10; // 2-digit
        int c = random.nextInt(9) + 1; // 1-digit
        currentExpression = "($a + $b) × $c";
        break;
      case "1_digit_times_2_digit_plus_2_digit":
        int a = random.nextInt(9) + 1; // 1-digit
        int b = random.nextInt(90) + 10; // 2-digit
        int c = random.nextInt(90) + 10; // 2-digit
        currentExpression = "$a × ($b + $c)";
        break;
      case "1_digit_times_2_digit_plus_1_digit_times_2_digit":
        int a = random.nextInt(9) + 1; // 1-digit
        int b = random.nextInt(90) + 10; // 2-digit
        int c = random.nextInt(9) + 1; // 1-digit
        int d = random.nextInt(90) + 10; // 2-digit
        currentExpression = "$a × $b + $c × $d";
        break;
      case "1_digit_times_3_digit_minus_2_digit_times_1_digit":
        int a = random.nextInt(9) + 1; // 1-digit
        int b = random.nextInt(900) + 100; // 3-digit
        int c = random.nextInt(90) + 10; // 2-digit
        int d = random.nextInt(9) + 1; // 1-digit
        currentExpression = "$a × $b - $c × $d";
        break;
      case "2_digit_times_2_digit_minus_2_digit_times_1_digit":
        int a = random.nextInt(90) + 10; // 2-digit
        int b = random.nextInt(90) + 10; // 2-digit
        int c = random.nextInt(90) + 10; // 2-digit
        int d = random.nextInt(9) + 1; // 1-digit
        currentExpression = "$a × $b - $c × $d";
        break;
      case "1_digit_plus_1_digit_times_1_digit_plus_1_digit":
        int a = random.nextInt(9) + 1; // 1-digit
        int b = random.nextInt(9) + 1; // 1-digit
        int c = random.nextInt(9) + 1; // 1-digit
        int d = random.nextInt(9) + 1; // 1-digit
        currentExpression = "($a + $b) × ($c + $d)";
        break;
      case "2_digit_minus_1_digit_divided_by_1_digit":
        int a = random.nextInt(90) + 10; // 2-digit
        int b = random.nextInt(9) + 1; // 1-digit
        int c = random.nextInt(9) + 1; // 1-digit (non-zero)
        currentExpression = "($a - $b) / $c";
        break;
      case "3_digit_plus_2_digit_divided_by_1_digit":
        int a = random.nextInt(900) + 100; // 3-digit
        int b = random.nextInt(90) + 10; // 2-digit
        int c = random.nextInt(9) + 1; // 1-digit (non-zero)
        currentExpression = "($a + $b) / $c";
        break;
      case "2_digit_times_1_digit_plus_2_digit_times_2_digit":
        int a = random.nextInt(90) + 10; // 2-digit
        int b = random.nextInt(9) + 1; // 1-digit
        int c = random.nextInt(90) + 10; // 2-digit
        int d = random.nextInt(90) + 10; // 2-digit
        currentExpression = "$a × $b + $c × $d";
        break;
      default:
        currentExpression = "Error: Unknown mode";
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
      // Helper to handle operations
      double operate(double a, double b, String op) {
        switch (op) {
          case '+':
            return a + b;
          case '-':
            return a - b;
          case '×':
            return a * b;
          case '/':
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
      case '/':
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

    setState(() {
      totalQuestionsAnswered++;

      if ((userAnswer - correctAnswer).abs() < 0.01) {
        correctAnswers++;
        if (totalQuestionsAnswered == 16) {
          _endGame();
        } else {
          _generateExpression();
        }
      } else {
        showingAnswer = true; // Show the correct answer for incorrect response
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

 // End the game
 void _endGame() {
  _stopwatch.stop();
  final elapsedTime = _stopwatch.elapsed;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xffffee9ae),
      title: Text(
        "Game Over!",
        style: GoogleFonts.mali(
          color: const Color.fromARGB(255, 50, 50, 50),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "Correct answers: $correctAnswers\n\n"
        "Time taken: ${elapsedTime.inMinutes}m ${elapsedTime.inSeconds % 60}s\n\n"
        "Do you want to continue to the next mission or choose a different mission?",
        style: GoogleFonts.mali(
          color: const Color.fromARGB(255, 50, 50, 50),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); 

            int nextMissionIndex = widget.missionIndex + 1;

            // Proceed to the next mission if available
            if (nextMissionIndex < CalmBearGameMixed.missionModes.length) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CalmBearGameMixed(
                    mode: CalmBearGameMixed.missionModes[nextMissionIndex],
                    missionIndex: nextMissionIndex,
                  ),
                ),
              );
            } else {
              // If no more missions are available, go back to the first screen
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
          child: Text(
            "Next Mission",
            style: GoogleFonts.mali(
              color: const Color.fromARGB(255, 50, 50, 50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); 
            Navigator.pop(context, correctAnswers); // Pass the correct answers back to the previous screen

            // Navigate back to the missions list 
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: Text(
            "Back to Missions",
            style: GoogleFonts.mali(
              color: const Color.fromARGB(255, 50, 50, 50),
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
          onPressed: () {
            Navigator.pop(context,
                correctAnswers); // Pass correct answers back when closing
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Correct: $correctAnswers",
                style: GoogleFonts.mali(
                  color: const Color(0xffffa400),
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
                      style: GoogleFonts.mali(
                        color: const Color(0xffffa400),
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    showingAnswer
                        ? Text(
                            "Correct Answer: ${_evaluateExpression(currentExpression).toStringAsFixed(2)}",
                            style: GoogleFonts.mali(
                              color: const Color(0xffffa400),
                              fontWeight: FontWeight.bold,
                              fontSize: 48,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            currentExpression,
                            style: GoogleFonts.mali(
                              color: const Color(0xffffa400),
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
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
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
                    const SizedBox(height: 10),
                  ],
                )
              : Text(
                  preStartTimer > 0 ? "$preStartTimer" : "Get Ready!",
                  style: GoogleFonts.mali(
                    color: const Color(0xffffa400),
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                  ),
                ),
        ),
      ),
    );
  }
}