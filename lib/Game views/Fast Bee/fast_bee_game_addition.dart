import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FastBeeGameAddition extends StatefulWidget {
  final String mode;
  final int missionIndex;

  const FastBeeGameAddition({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "add_1_digit",
    "add_1_digit_and_2_digit",
    "add_2_digit_without_carry",
    "add_2_digit_with_carry",
    "add_3_digit_and_2_digit",
    "add_3_digit",
    "add_4_digit_and_2_digit",
    "add_4_digit_and_3_digit",
    "add_4_digit",
    "add_decimals",
  ];

  @override
  State<FastBeeGameAddition> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameAddition> {
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

  @override
  void initState() {
    super.initState();
    timeLeft =
        widget.missionIndex >= 5 ? 120 : 90; // Adjust time based on mission
    _focusNode = FocusNode();
    _controller = TextEditingController();
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

    if (widget.mode == "add_1_digit") {
      int a = random.nextInt(9) + 1; // 1-digit (1-9)
      int b = random.nextInt(9) + 1; // 1-digit (1-9)
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_1_digit_and_2_digit") {
      int a = random.nextInt(9) + 1; // 1-digit (1-9)
      int b = random.nextInt(90) + 10; // 2-digit (10-99)
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_2_digit_without_carry") {
      int a = random.nextInt(80) + 10; // Generate first 2-digit number (10-89)
      int b = random.nextInt(80) + 10; // Generate second 2-digit number (10-89)
      int unitsA = a % 10; // Get the unit place of a
      int maxUnitsB =
          9 - unitsA; // Max value for the units digit of b to avoid carry
      int unitsB = random.nextInt(
          maxUnitsB + 1); // Generate units digit for b within the limit
      b = (b ~/ 10) * 10 +
          unitsB; // Replace the unit digit of b while keeping the tens digit intact
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_2_digit_with_carry") {
      int a = random.nextInt(90) + 10; // 2-digit
      int b = random.nextInt(90) + 10; // 2-digit
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_3_digit_and_2_digit") {
      int a = random.nextInt(800) + 100; // 3-digit
      int b = random.nextInt(90) + 10; // 2-digit
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_3_digit") {
      int a = random.nextInt(800) + 100; // 3-digit
      int b = random.nextInt(800) + 100; // 3-digit
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_4_digit_and_2_digit") {
      int a = random.nextInt(9000) + 1000; // 4-digit
      int b = random.nextInt(90) + 10; // 2-digit
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_4_digit_and_3_digit") {
      int a = random.nextInt(9000) + 1000; // 4-digit
      int b = random.nextInt(800) + 100; // 3-digit
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_4_digit") {
      int a = random.nextInt(9000) + 1000; // 4-digit
      int b = random.nextInt(9000) + 1000; // 4-digit
      currentExpression = "$a + $b";
    } else if (widget.mode == "add_decimals") {
      double a = (random.nextInt(90000) + 10000) / 100; // Range 100.00 - 999.99
      double b = (random.nextInt(9000) + 1000) / 100; // Range 10.00 - 99.99
      currentExpression = "${a.toStringAsFixed(2)} + ${b.toStringAsFixed(1)}";
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
      final parts = expression.split(" + ");
      double a = double.parse(parts[0]);
      double b = double.parse(parts[1]);
      return a + b;
    } catch (e) {
      return 0.0;
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
          _generateExpression();
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

  // End the game
  void _endGame() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xffffee9ae),
        title: Text(
          "Time's Up!",
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

              if (nextMissionIndex < FastBeeGameAddition.missionModes.length) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameAddition(
                      mode: FastBeeGameAddition.missionModes[nextMissionIndex],
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
            Navigator.pop(context, correctAnswers);
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
                    "Answered: $totalQuestionsAnswered",
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
