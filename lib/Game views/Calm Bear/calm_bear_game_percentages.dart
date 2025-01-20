import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalmBearGamePercentages extends StatefulWidget {
  final String mode;
  final int missionIndex;

  const CalmBearGamePercentages({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "10_percent_of_2_digit_or_3_digit",
    "20_percent_of_2_digit_or_3_digit",
    "50_percent_of_1_digit_2_digit_or_3_digit",
    "20_25_50_percent_of_2_digit_3_digit_or_4_digit",
    "2_digit_plus_10_20_25_or_50_percent",
    "2_digit_minus_10_20_25_or_50_percent",
    "30_percent_of_3_digit",
    "3_digit_plus_10_20_25_or_50_percent",
    "1_digit_percent_of_2_digit",
    "2_digit_percent_of_2_digit",
  ];

  @override
  State<CalmBearGamePercentages> createState() => _CalmBearGameState();
}

class _CalmBearGameState extends State<CalmBearGamePercentages> {
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

    if (widget.mode == "10_percent_of_2_digit_or_3_digit") {
      int a = random.nextInt(900) + 10; // 3-digit (10-999)
      currentExpression = "10% of $a";
    } else if (widget.mode == "20_percent_of_2_digit_or_3_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-999)
      currentExpression = "20% of $a";
    } else if (widget.mode == "50_percent_of_1_digit_2_digit_or_3_digit") {
      int a = random.nextInt(1000); // 1- to 3-digit (0-999)
      currentExpression = "50% of $a";
    } else if (widget.mode ==
        "20_25_50_percent_of_2_digit_3_digit_or_4_digit") {
      int a = random.nextInt(9000) + 10; // 3- or 4-digit (100-9999)
      List<int> percentages = [20, 25, 50];
      int percent = percentages[random.nextInt(percentages.length)];
      currentExpression = "$percent% of $a";
    } else if (widget.mode == "2_digit_plus_10_20_25_or_50_percent") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      List<int> percentages = [10, 20, 25, 50];
      int percent = percentages[random.nextInt(percentages.length)];
      currentExpression = "$a + $percent%";
    } else if (widget.mode == "2_digit_minus_10_20_25_or_50_percent") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      List<int> percentages = [10, 20, 25, 50];
      int percent = percentages[random.nextInt(percentages.length)];
      currentExpression = "$a - $percent%";
    } else if (widget.mode == "30_percent_of_3_digit") {
      int a = random.nextInt(900) + 100; // 3-digit (100-999)
      currentExpression = "30% of $a";
    } else if (widget.mode == "3_digit_plus_10_20_25_or_50_percent") {
      int a = random.nextInt(900) + 100; // 3-digit (100-999)
      List<int> percentages = [10, 20, 25, 50];
      int percent = percentages[random.nextInt(percentages.length)];
      currentExpression = "$a + $percent%";
    } else if (widget.mode == "1_digit_percent_of_2_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      int percent = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$percent% of $a";
    } else if (widget.mode == "2_digit_percent_of_2_digit") {
      int a = random.nextInt(90) + 10; // 2-digit (10-99)
      int percent = random.nextInt(90) + 10; // 2-digit (10-99)
      currentExpression = "$percent% of $a";
    }

    setState(() {
      userInput = "";
      _controller.text = ""; // Reset input field
      _focusNode
          .requestFocus(); // Request focus after generating new expression
    });
  }

  double _evaluateExpression(String expression) {
    try {
      if (expression.contains(" of ")) {
        // Handle percentage calculations like "20% of 150"
        final parts = expression.split(" of ");
        double percentage = double.parse(parts[0].replaceAll("%", "").trim());
        double value = double.parse(parts[1].trim());
        return (percentage / 100) * value;
      } else if (expression.contains("+") && expression.contains("%")) {
        // Handle addition with percentage like "150 + 10%"
        final parts = expression.split(" + ");
        double baseValue = double.parse(parts[0].trim());
        double percentage = double.parse(parts[1].replaceAll("%", "").trim());
        return baseValue + (percentage / 100) * baseValue;
      } else if (expression.contains("-") && expression.contains("%")) {
        // Handle subtraction with percentage like "150 - 10%"
        final parts = expression.split(" - ");
        double baseValue = double.parse(parts[0].trim());
        double percentage = double.parse(parts[1].replaceAll("%", "").trim());
        return baseValue - (percentage / 100) * baseValue;
      }
    } catch (e) {
      // Log error for debugging
      print("Error evaluating expression: $e");
      return 0.0;
    }
    return 0.0;
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
    _stopwatch.stop(); // Stop the stopwatch
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

              if (nextMissionIndex < CalmBearGamePercentages.missionModes.length) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalmBearGamePercentages(
                      mode: CalmBearGamePercentages.missionModes[nextMissionIndex],
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
                        setState(() {
                          userInput = value;
                        });
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
