import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FastBeeGameSubtraction extends StatefulWidget {
  // I think all expressions work
  final String mode;
  final int missionIndex;

  const FastBeeGameSubtraction({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "sub_2_digit_and_1_digit",
    "sub_2_digit",
    "sub_3_digit_and_1_digit_or_2_digit_without_carry",
    "sub_3_digit_and_1_digit_or_2_digit_with_carry",
    "sub_3_digit_and_2_digit_and_1_digit",
    "sub_3_digit",
    "sub_4_digit_and_2_digit",
    "sub_4_digit_and_3_digit",
    "sub_4_digit",
    "sub_decimals",
  ];

  @override
  State<FastBeeGameSubtraction> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameSubtraction> {
  late Timer _timer;
  int timeLeft = 90;
  int preStartTimer = 5;
  int correctAnswers = 0;
  int totalQuestionsAnswered = 1; // Track total questions answered
  String currentExpression = "";
  String userInput = "";
  bool gameStarted = false;
  bool canSkip = false;
  late TextEditingController _controller;
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

  void _generateExpression() {
    final random = Random();

    if (widget.mode == "sub_2_digit_and_1_digit") {
      int a = random.nextInt(90) + 10; // 10 to 99
      int b = random.nextInt(9) + 1; // 1 to 9
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_2_digit") {
      int a = random.nextInt(90) + 10; // 10 to 99
      int b = random.nextInt(90) + 10; // 10 to 99
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode ==
        "sub_3_digit_and_1_digit_or_2_digit_without_carry") {
      // should be without carry over
      int a = random.nextInt(800) + 100; // 100 to 999
      int b = random.nextInt(99) + 1; // 1 to 99
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_3_digit_and_1_digit_or_2_digit_with_carry") {
      // should be with carry over
      int a = random.nextInt(800) + 100; // 100 to 999
      int b = random.nextInt(99) + 1; // 1 to 99
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_3_digit_and_2_digit_and_1_digit") {
      int a = random.nextInt(800) + 100; // 100 to 999
      int b = random.nextInt(99) + 1; // 1 to 99
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_3_digit") {
      int a = random.nextInt(800) + 100; // 100 to 999
      int b = random.nextInt(800) + 100; // 100 to 999
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_4_digit_and_2_digit") {
      int a = random.nextInt(9000) + 1000; // 1000 to 9999
      int b = random.nextInt(90) + 10; // 10 to 99
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_4_digit_and_3_digit") {
      int a = random.nextInt(9000) + 1000; // 1000 to 9999
      int b = random.nextInt(900) + 100; // 100 to 999
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_4_digit") {
      int a = random.nextInt(9000) + 1000; // 1000 to 9999
      int b = random.nextInt(9000) + 1000; // 1000 to 9999
      if (b > a) {
        int temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "$a - $b";
    } else if (widget.mode == "sub_decimals") {
      double a = (random.nextInt(900) + 100) / 10.0; // 10.0 to 99.9
      double b = (random.nextInt(90) + 10) / 10.0; // 1.0 to 9.9
      if (b > a) {
        double temp = a;
        a = b;
        b = temp; // Ensure a >= b
      }
      currentExpression = "${a.toStringAsFixed(1)} - ${b.toStringAsFixed(1)}";
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

  double _evaluateExpression(String expression) {
    try {
      final parts = expression.split(" ");
      double a = double.parse(parts[0]);
      double b = double.parse(parts[2]);
      return a - b;
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
                  FastBeeGameSubtraction.missionModes.length) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameSubtraction(
                      mode:
                          FastBeeGameSubtraction.missionModes[nextMissionIndex],
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
