import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalmBearGameMultiplication extends StatefulWidget {
  final String mode;
  final int missionIndex;

  const CalmBearGameMultiplication({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "mult_1_digit",
    "mult_1_digit_by_2_digit",
    "mult_2_digit_by_1_digit",
    "mult_3_digit_by_1_digit_or_vice_versa",
    "mult_4_digit_by_1_digit",
    "mult_2_digit",
    "mult_1_digit_by_1_digit_by_1_digit",
    "mult_2_digit_by_1_digit_by_1_digit",
    "mult_decimal_or_two_decimals_by_1_digit",
    "mult_decimals",
  ];

  @override
  State<CalmBearGameMultiplication> createState() => _CalmBearGameState();
}

class _CalmBearGameState extends State<CalmBearGameMultiplication> {
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

    if (widget.mode == "mult_1_digit") {
      int a = random.nextInt(9) + 1; // 1-digit (1-9)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a x $b";
    } else if (widget.mode == "mult_1_digit_by_2_digit") {
      int a = random.nextInt(9) + 1; // 1-digit (1-9)
      int b = random.nextInt(90) + 10; // 2-digit (10-99)
      currentExpression = "$a x $b";
    } else if (widget.mode == "mult_2_digit_by_1_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a x $b";
    } else if (widget.mode == "mult_3_digit_by_1_digit_or_vice_versa") {
      // Fourth & Fifth Mission: 3-digit x 1-digit or 1-digit x 3-digit
      int a = random.nextBool()
          ? random.nextInt(90) + 10
          : random.nextInt(9) + 1; // Either 3-digit or 1-digit
      int b = (a > 99)
          ? random.nextInt(9) + 1
          : random.nextInt(900) + 100; // Match the other number
      currentExpression = "$a x $b";
    } else if (widget.mode == "mult_4_digit_by_1_digit") {
      int a = random.nextInt(9000) + 1000; // 4-digit (1000-9999)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a x $b";
    } else if (widget.mode == "mult_2_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      int b = random.nextInt(90) + 10; // 2-digit (10-99)
      currentExpression = "$a x $b";
    } else if (widget.mode == "mult_1_digit_by_1_digit_by_1_digit") {
      int a = random.nextInt(9) + 1; // 1-digit (1-9)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      int c = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a x $b x $c";
    } else if (widget.mode == "mult_2_digit_by_1_digit_by_1_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      int c = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a x $b x $c";
    } else if (widget.mode == "mult_decimal_or_two_decimals_by_1_digit") {
      // Ninth Mission: x.x * 1-digit or xx.xx * 1-digit
      bool twoDecimals =
          random.nextBool(); // Randomly pick between x.x and xx.xx
      double a = twoDecimals
          ? (random.nextInt(9000) + 1000) / 100.0 // xx.xx (10.00 - 99.99)
          : (random.nextInt(90) + 10) / 10.0; // x.x (1.0 - 9.9)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "${a.toStringAsFixed(twoDecimals ? 2 : 1)} x $b";
    } else if (widget.mode == "mult_decimals") {
      double a = (random.nextInt(90) + 10) / 10.0; // Decimal (1.0 - 9.9)
      double b = (random.nextInt(90) + 10) / 10.0; // Decimal (1.0 - 9.9)
      currentExpression = "${a.toStringAsFixed(1)} x ${b.toStringAsFixed(1)}";
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

    // Show the dialog first
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
              Navigator.pop(context); // Closes the dialog

              int nextMissionIndex = widget.missionIndex + 1;

              // Proceed to the next mission if available
              if (nextMissionIndex <
                  CalmBearGameMultiplication.missionModes.length) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalmBearGameMultiplication(
                      mode: CalmBearGameMultiplication
                          .missionModes[nextMissionIndex],
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
