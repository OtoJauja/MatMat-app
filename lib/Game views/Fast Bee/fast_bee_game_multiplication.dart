import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FastBeeGameMultiplication extends StatefulWidget {
  // The expressions should work properly
  final String mode;
  final int missionIndex;

  const FastBeeGameMultiplication({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "mult_1_digit",
    "mult_1_digit_by_2_digit",
    "mult_2_digit_by_1_digit",
    "mult_3_digit_by_1_digit",
    "mult_4_digit_by_1_digit",
    "mult_2_digit",
    "mult_1_digit_by_1_digit_by_1_digit",
    "mult_2_digit_by_1_digit_by_1_digit",
    "mult_decimal_by_1_digit",
    "mult_decimals",
  ];

  @override
  State<FastBeeGameMultiplication> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameMultiplication> {
  late Timer _timer; // Countdown timer
  int timeLeft = 90; // 90 seconds to complete
  int preStartTimer = 5; // Countdown before the game starts
  int correctAnswers = 0; // Track correct answers
  int totalQuestionsAnswered = 1; // Track total questions answered
  String currentExpression = ""; // Current math expression
  String userInput = ""; // User's input
  bool gameStarted = false; // Flag to indicate game has started
  bool canSkip = false; // Sets the skip button to false
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

    if (widget.mode == "mult_1_digit") {
      int a = random.nextInt(9) + 1; // 1-digit (1-9)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a * $b";
    } else if (widget.mode == "mult_1_digit_by_2_digit") {
      int a = random.nextInt(9) + 1; // 1-digit (1-9)
      int b = random.nextInt(90) + 10; // 2-digit (10-99)
      currentExpression = "$a * $b";
    } else if (widget.mode == "mult_2_digit_by_1_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a * $b";
    } else if (widget.mode == "mult_3_digit_by_1_digit") {
      int a = random.nextInt(900) + 100; // 3-digit (100-999)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a * $b";
    } else if (widget.mode == "mult_4_digit_by_1_digit") {
      int a = random.nextInt(9000) + 1000; // 4-digit (1000-9999)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a * $b";
    } else if (widget.mode == "mult_2_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      int b = random.nextInt(90) + 10; // 2-digit (10-99)
      currentExpression = "$a * $b";
    } else if (widget.mode == "mult_1_digit_by_1_digit_by_1_digit") {
      int a = random.nextInt(9) + 1; // 1-digit (1-9)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      int c = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a * $b * $c";
    } else if (widget.mode == "mult_2_digit_by_1_digit_by_1_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      int c = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a * $b * $c";
    } else if (widget.mode == "mult_decimal_by_1_digit") {
      double a = (random.nextInt(90) + 10) / 10.0; // Decimal (1.0 - 9.9)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "${a.toStringAsFixed(1)} * $b";
    } else if (widget.mode == "mult_decimals") {
      double a = (random.nextInt(90) + 10) / 10.0; // Decimal (1.0 - 9.9)
      double b = (random.nextInt(90) + 10) / 10.0; // Decimal (1.0 - 9.9)
      currentExpression = "${a.toStringAsFixed(1)} * ${b.toStringAsFixed(1)}";
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
      final parts = expression.split(" ");

      if (parts.length == 5) {
        double a = double.parse(parts[0]);
        double b = double.parse(parts[2]);
        double c = double.parse(parts[4]);
        return a * b * c;
      } else if (parts.length == 3) {
        double a = double.parse(parts[0]);
        double b = double.parse(parts[2]);
        return a * b;
      }

      return double.nan;
    } catch (e) {
      return double.nan;
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

              if (nextMissionIndex <
                  FastBeeGameMultiplication.missionModes.length) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameMultiplication(
                      mode: FastBeeGameMultiplication
                          .missionModes[nextMissionIndex],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                  color: const Color(0xffffa400),
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
                    "$totalQuestionsAnswered of 15",
                    style: GoogleFonts.mali(
                      color: const Color(0xffffa400),
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "⏳ $timeLeft seconds",
                    style: GoogleFonts.mali(
                      color: const Color(0xffffa400),
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
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
                  color: const Color(0xffffa400),
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
      ),
    );
  }
}
