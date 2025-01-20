import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    "div_2_digit_by_1_digit",
    "div_3_digit_by_1_digit",
    "div_4_digit_by_1_digit",
    "div_2_digit",
    "div_3_digit_by_2_digit",
    "div_3_digit_by_1_digit_by_1_digit",
    "div_4_digit_by_1_digit_by_1_digit",
    "div_decimals_by_1_digit_or_2_digit",
    "div_decimals",
  ];

  @override
  State<FastBeeGameDivision> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameDivision> {
  late Timer _timer; // Countdown timer
  int timeLeft = 90; // 90 seconds to complete
  int preStartTimer = 5; // Countdown before the game starts
  int correctAnswers = 0; // Track correct answers
  int totalQuestionsAnswered = 1; // Track total questions answered
  String currentExpression = ""; // Current math expression
  String userInput = ""; // User's input
  List<String> mistakes = []; // List of incorrect expressions
  bool gameStarted = false; // Flag to indicate game has started
  bool canSkip = false;
  late TextEditingController _controller; // Persistent controller
  late FocusNode _focusNode; // Focus to autoclick input

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _startPreGameTimer();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Timer for 5-second pre-game countdown
  void _startPreGameTimer() {
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

    if (widget.mode == "div_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a = random.nextInt(9) + 1;
      currentExpression = "$a / $b";
    } else if (widget.mode == "div_2_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = (random.nextInt(90) + 10); // Generate a 2-digit number
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a / $b";
    } else if (widget.mode == "div_3_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = (random.nextInt(900) + 100); // Generate a 3-digit number
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a / $b";
    } else if (widget.mode == "div_4_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = (random.nextInt(900) + 1000); // Generate a 4-digit number
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a / $b";
    } else if (widget.mode == "div_2_digit") {
      int b = random.nextInt(90) + 10; // Divisor
      int a;
      do {
        a = (random.nextInt(90) + 10); // Generate a 2-digit number
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a / $b";
    } else if (widget.mode == "div_3_digit_by_2_digit") {
      int b = random.nextInt(90) + 10; // Divisor
      int a;
      do {
        a = (random.nextInt(900) + 100); // Generate a 3-digit number
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a / $b";
    } else if (widget.mode == "div_3_digit_by_1_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // First divisor
      int c = random.nextInt(9) + 1; // Second divisor
      int a;
      do {
        a = random.nextInt(900) + 100; // Generate a 3-digit number
      } while (a % b != 0 ||
          (a ~/ b) % c != 0); // Ensure no remainders in both steps
      currentExpression = "$a / $b / $c";
    } else if (widget.mode == "div_4_digit_by_1_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // First divisor
      int c = random.nextInt(9) + 1; // Second divisor
      int a;
      do {
        a = random.nextInt(9000) + 1000; // Generate a 4-digit number
      } while (a % b != 0 ||
          (a ~/ b) % c != 0); // Ensure no remainders in both steps
      currentExpression = "$a / $b / $c";
    } else if (widget.mode == "div_decimals_by_1_digit_or_2_digit") {
      int b; // Whole number divisor
      double a; // Decimal dividend
      do {
        b = random.nextInt(90) + 10; // Generate divisor (10-99)
        int multiplier =
            random.nextInt(900) + 100; // Generate a multiplier (100-999)
        a = (b * multiplier) / 100.0; // Generate dividend as xxx.xx format
      } while ((a * 100).toInt() % b != 0 || a < 100.0 || a >= 1000.0);
      currentExpression =
          "${a.toStringAsFixed(2)} / $b"; // Ensure two decimal places for 'a'
    } else if (widget.mode == "div_decimals") {
      double b; // Decimal divisor (x.x format)
      double a; // Decimal dividend (xx.xx format)
      do {
        b = (random.nextInt(90) + 10) /
            10.0; // Generate divisor in the range 1.0 - 9.9
        int multiplier =
            random.nextInt(900) + 100; // Generate a multiplier (100-999)
        a = (b * multiplier) /
            100.0; // Generate dividend in the range 10.00 - 99.99
      } while ((a * 100).toInt() % (b * 10).toInt() != 0 ||
          a < 9.9 ||
          a >= 100.0 ||
          b < 0.9 ||
          b >= 9.9);
      currentExpression = "${a.toStringAsFixed(2)} / ${b.toStringAsFixed(1)}";
    }
    if (mounted == true) {
      setState(() {
        userInput = "";
        _controller.text = "";
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

  // End the game
  void _endGame() {
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

              if (nextMissionIndex < FastBeeGameDivision.missionModes.length) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameDivision(
                      mode: FastBeeGameDivision.missionModes[nextMissionIndex],
                      missionIndex: nextMissionIndex,
                    ),
                  ),
                );
              } else {
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

  // Evaluate a math expression
  double _evaluateExpression(String expression) {
    try {
      final parts = expression.split(" / ");
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

    // Normalize commas in input and parse as double
    double userAnswer =
        double.tryParse(userInput.replaceAll(",", ".")) ?? double.nan;

    if ((userAnswer - correctAnswer).abs() < 0.01) {
      if (mounted == true) {
        setState(() {
          correctAnswers++;
          totalQuestionsAnswered++;
          if (totalQuestionsAnswered == 16) {
            _endGame();
          } else {
            _generateExpression();
          }
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffa400),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Correct: $correctAnswers",
                style: GoogleFonts.mali(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xffffa400),
      body: Center(
        child: gameStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$totalQuestionsAnswered of 15",
                    style: GoogleFonts.mali(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "⏳ $timeLeft seconds",
                    style: GoogleFonts.mali(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentExpression,
                    style: GoogleFonts.mali(
                      color: const Color.fromARGB(255, 255, 255, 255),
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
                    child: Text(
                      "Skip",
                      style: GoogleFonts.mali(
                        color: const Color.fromARGB(255, 50, 50, 50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                preStartTimer > 0 ? "$preStartTimer" : "Get Ready!",
                style: GoogleFonts.mali(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
      ),
    );
  }
}
