import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalmBearGameExponentiation extends StatefulWidget {
  final String mode;
  final int missionIndex;

  const CalmBearGameExponentiation({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "1_digit_squared",
    "2_digit_squared",
    "1_digit_cubed",
    "1_digit_squared_plus_1_digit_squared",
    "1_digit_cubed_minus_1_digit_squared",
    "square_root_of_1_digit_2_digit_3_digit",
    "cubic_root_of_1_digit_2_digit_3_digit",
    "square_root_of_1_digit_or_2_digit_plus_1_digit",
    "square_root_of_2_digit_times_square_root_of_2_digit",
    "square_root_of_2_digit_divided_square_root_of_2_digit_or_3_digit",
  ];

  @override
  State<CalmBearGameExponentiation> createState() => _CalmBearGameState();
}

class _CalmBearGameState extends State<CalmBearGameExponentiation> {
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

  // Generate a random math expression 
  void _generateExpression() {
    final random = Random();

    switch (widget.mode) {
      case "1_digit_squared":
        int a = random.nextInt(9) + 1;
        currentExpression = "$a²";
        break;
      case "2_digit_squared":
        int a = random.nextInt(90) + 10;
        currentExpression = "$a²";
        break;
      case "1_digit_cubed":
        int a = random.nextInt(9) + 1;
        currentExpression = "$a³";
        break;
      case "1_digit_squared_plus_1_digit_squared":
        int a = random.nextInt(9) + 1;
        int b = random.nextInt(9) + 1;
        currentExpression = "$a² + $b²";
        break;
      case "1_digit_cubed_minus_1_digit_squared":
        int a = random.nextInt(9) + 1;
        int b = random.nextInt(9) + 1;
        currentExpression = "$a³ - $b²";
        break;
      case "square_root_of_1_digit_2_digit_3_digit":
        List<int> perfectSquares = [for (int i = 2; i <= 31; i += 2) i * i];
        int a = perfectSquares[random.nextInt(perfectSquares.length)];
        currentExpression = "√$a";
        break;
      case "cubic_root_of_1_digit_2_digit_3_digit":
        int a = [
          pow(1, 3).toInt(),
          pow(2, 3).toInt(),
          pow(3, 3).toInt(),
          pow(4, 3).toInt(),
          pow(5, 3).toInt(),
        ][random.nextInt(5)];
        currentExpression = "∛$a";
        break;
      case "square_root_of_1_digit_or_2_digit_plus_1_digit":
        List<int> perfectSquares1 = [
          for (int i = 1; i <= 9; i++) i * i // 1² to 9²
        ];
        int a = perfectSquares1[random.nextInt(perfectSquares1.length)];
        int b = random.nextInt(9) + 1; // 1-9
        currentExpression = "√$a + $b";
        break;
      case "square_root_of_2_digit_times_square_root_of_2_digit":
        List<int> perfectSquares2Digit = [
          for (int i = 4; i <= 9; i++) i * i // 16, 36, 64, 81
        ];
        int a =
            perfectSquares2Digit[random.nextInt(perfectSquares2Digit.length)];
        int b =
            perfectSquares2Digit[random.nextInt(perfectSquares2Digit.length)];
        currentExpression = "√$a * √$b";
        break;
      case "square_root_of_2_digit_divided_square_root_of_2_digit_or_3_digit":
        List<int> perfectSquares2DigitOr3Digit = [
          for (int i = 4; i <= 31; i++) i * i // Perfect squares from 4² to 31²
        ];

        int a, b;
        do {
          a = perfectSquares2DigitOr3Digit[
              random.nextInt(perfectSquares2DigitOr3Digit.length)];
          b = perfectSquares2DigitOr3Digit[
              random.nextInt(perfectSquares2DigitOr3Digit.length)];
        } while (
            sqrt(a) % sqrt(b) != 0 || a == b); // Ensure divisibility and a != b

        currentExpression = "√$a / √$b";
        break;
    }

    setState(() {
      userInput = "";
      _controller.text = ""; // Reset input field
      _focusNode
          .requestFocus(); // Request focus after generating new expression
    });
  }

  // Evaluate a math expression
  int _evaluateExpression(String expression) {
    try {
      // Handle square roots
      if (expression.contains("√")) {
        // Parse square root expressions
        if (expression.contains("*")) {
          var parts = expression.split("*");
          int left = _evaluateExpression(parts[0].trim());
          int right = _evaluateExpression(parts[1].trim());
          return left * right;
        } else if (expression.contains("/")) {
          var parts = expression.split("/");
          int left = _evaluateExpression(parts[0].trim());
          int right = _evaluateExpression(parts[1].trim());
          return left ~/ right;
        } else if (expression.contains("+")) {
          var parts = expression.split("+");
          int left = _evaluateExpression(parts[0].trim());
          int right = _evaluateExpression(parts[1].trim());
          return left + right;
        } else if (expression.contains("-")) {
          var parts = expression.split("-");
          int left = _evaluateExpression(parts[0].trim());
          int right = _evaluateExpression(parts[1].trim());
          return left - right;
        } else {
          // Simple square root
          String baseStr = expression.replaceAll(RegExp(r"[√ ]"), "");
          int base = int.parse(baseStr);
          return sqrt(base).toInt();
        }
      }

      // Handle cubic roots
      if (expression.contains("∛")) {
        String baseStr = expression.replaceAll(RegExp(r"[∛ ]"), "");
        int base = int.parse(baseStr);
        return pow(base, 1 / 3).round();
      }

      // Handle squares
      if (expression.contains("²")) {
        int base = int.parse(expression.replaceAll("²", ""));
        return pow(base, 2).toInt();
      }

      // Handle cubes
      if (expression.contains("³")) {
        int base = int.parse(expression.replaceAll("³", ""));
        return pow(base, 3).toInt();
      }

      // Handle addition
      if (expression.contains("+")) {
        var parts = expression.split("+");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left + right;
      }

      // Handle subtraction
      if (expression.contains("-")) {
        var parts = expression.split("-");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left - right;
      }

      // Handle multiplication
      if (expression.contains("*")) {
        var parts = expression.split("*");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left * right;
      }

      // Handle division
      if (expression.contains("/")) {
        var parts = expression.split("/");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left ~/ right;
      }
    } catch (e) {
      return 0; // Return 0 if there's an error
    }

    // If the expression is a plain number
    return int.tryParse(expression) ?? 0;
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

              if (nextMissionIndex < CalmBearGameExponentiation.missionModes.length) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalmBearGameExponentiation(
                      mode: CalmBearGameExponentiation.missionModes[nextMissionIndex],
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
      body: Container(
        color: const Color(0xffffa400),
        child: Center(
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
                    showingAnswer
                        ? Text(
                            "Correct Answer: ${_evaluateExpression(currentExpression).toStringAsFixed(2)}",
                            style: GoogleFonts.mali(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 48,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            currentExpression,
                            style: GoogleFonts.mali(
                              color: Colors.white,
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                  ),
                ),
        ),
      ),
    );
  }
}
