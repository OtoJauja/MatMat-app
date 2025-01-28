import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    if (widget.mode == "div_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = random.nextBool() ? random.nextInt(90) + 10 : random.nextInt(9) + 1;
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a ÷ $b";
    } else if (widget.mode ==
        "div_1_or_2_digit_by_1_digit_with_decimal_result") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = random.nextInt(90) + 1; // Numerator (1-99)
      } while (a % b == 0); // Ensure result is decimal
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_3_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = random.nextInt(900) + 100; // Generate a 3-digit number
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_4_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // Divisor
      int a;
      do {
        a = random.nextInt(9000) + 1000; // Generate a 4-digit number
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_2_digit") {
      // Fifth mission: Reduce identical numbers
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
        a = random.nextInt(900) + 100; // Generate a 3-digit number
      } while (a % b != 0); // Ensure no remainder
      currentExpression = "$a ÷ $b";
    } else if (widget.mode == "div_3_digit_by_1_digit_by_1_digit") {
      int b = random.nextInt(9) + 1; // First divisor
      int c = random.nextInt(9) + 1; // Second divisor
      int a;
      do {
        a = random.nextInt(900) + 100; // Generate a 3-digit number
      } while (a % b != 0 ||
          (a ~/ b) % c != 0); // Ensure no remainders in both steps
      currentExpression = "$a ÷ $b ÷ $c";
    } else if (widget.mode == "div_decimals_by_1_digit") {
      // Seventh mission: Decimals (xxx.xx) divided by 1-digit
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
        a = random.nextInt(9000) + 1000; // Generate a 4-digit number
      } while (a % b != 0 ||
          (a ~/ b) % c != 0); // Ensure no remainders in both steps
      currentExpression = "$a ÷ $b ÷ $c";
    } else if (widget.mode == "div_decimals_by_2_digit") {
      // Tenth mission: Decimals (xxx.xx) divided by 2-digit
      int b;
      double a;
      do {
        b = random.nextInt(90) + 10; // Divisor (10-99)
        int multiplier = random.nextInt(90000) + 10000; // Multiplier for xxx.xx
        a = multiplier / 100.0;
      } while ((a * 100).toInt() % b != 0); // Ensure result is valid
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
              if (nextMissionIndex < CalmBearGameDivision.missionModes.length) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalmBearGameDivision(
                      mode: CalmBearGameDivision.missionModes[nextMissionIndex],
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
              Navigator.pop(context,
                  correctAnswers); // Pass the correct answers back to the previous screen

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
