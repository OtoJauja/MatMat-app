// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Services/mission_provider_calm.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    "square_of_2_digit_divided_square_root_of_2_digit_or_3_digit",
  ];

  @override
  State<CalmBearGameExponentiation> createState() => _CalmBearGameState();
}

class _CalmBearGameState extends State<CalmBearGameExponentiation> {
  int sessionScore = 0;
  int highestScore = 0;
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
    String key = "Exponentiation_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;
    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "Exponentiation_highestScore_$missionIndex";
    return prefs.getInt(key) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _loadHighestScore(widget.missionIndex).then((value) {
      if (mounted) {
        setState(() {
          highestScore = value;
          sessionScore = 0;
        });
      }
    });
    _startPreGameTimer();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startPreGameTimer() {
    setState(() {
      sessionScore = 0;
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
      case "1_digit_squared":
        int a = random.nextInt(9) + 1;
        currentExpression = "$a²";
        break;
      case "2_digit_squared":
        int a = random.nextInt(11) + 10; // 10 to 20
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
        // Ensure the first number is larger than the second
        if (a <= b) {
          int temp = a;
          a = b;
          b = temp;
          if (a == b) {
            // Adjust if they end up equal
            b = (a > 1) ? a - 1 : a + 1;
          }
        }
        currentExpression = "$a³ - $b²";
        break;
      case "square_root_of_1_digit_2_digit_3_digit":
        List<int> perfectSquares = [for (int i = 2; i <= 31; i += 2) i * i];
        int a = perfectSquares[random.nextInt(perfectSquares.length)];
        currentExpression = "√$a";
        break;
      case "cubic_root_of_1_digit_2_digit_3_digit":
        // Exclude 1 by starting at 2
        int a = [
          pow(2, 3).toInt(),
          pow(3, 3).toInt(),
          pow(4, 3).toInt(),
          pow(5, 3).toInt(),
          pow(6, 3).toInt(),
        ][random.nextInt(5)];
        currentExpression = "∛$a";
        break;
      case "square_root_of_1_digit_or_2_digit_plus_1_digit":
        List<int> perfectSquares1 = [for (int i = 1; i <= 9; i++) i * i];
        int a = perfectSquares1[random.nextInt(perfectSquares1.length)];
        int b = random.nextInt(9) + 1;
        // Change the expression to add a 1-digit squared.
        currentExpression = "√$a + $b²";
        break;
      case "square_root_of_2_digit_times_square_root_of_2_digit":
        List<int> perfectSquares2Digit = [16, 25, 36, 49, 64, 81];
        int a = perfectSquares2Digit[random.nextInt(perfectSquares2Digit.length)];
        int b = perfectSquares2Digit[random.nextInt(perfectSquares2Digit.length)];
        currentExpression = "√$a x √$b";
        break;
      case "square_of_2_digit_divided_square_root_of_2_digit_or_3_digit":
      List<int> twoDigitSquares = [16, 25, 36, 49, 64, 81];
      List<int> threeDigitSquares = [
        100, 121, 144, 169, 196, 225, 256, 289, 324, 361,
        400, 441, 484, 529, 576, 625, 676, 729, 784, 841, 900, 961
      ];
      bool chooseTwoDigit = random.nextBool();
      int b;
      if (chooseTwoDigit) {
        b = twoDigitSquares[random.nextInt(twoDigitSquares.length)];
      } else {
        b = threeDigitSquares[random.nextInt(threeDigitSquares.length)];
      }
      int divisor = sqrt(b).toInt(); // Whole number
      List<int> candidates = [];
      for (int i = 10; i <= 99; i++) {
        if (i % divisor == 0) {
          candidates.add(i);
        }
      }
      if (candidates.isEmpty) {
        candidates = [10, 20, 30];
      }
      int a = candidates[random.nextInt(candidates.length)];
      
      currentExpression = "$a² ÷ √$b";
      break;
      default:
        currentExpression = "";
    }
    if (mounted) {
      setState(() {
        userInput = "";
        _controller.text = "";
        showingAnswer = false;
      });
    }
    Future.delayed(Duration.zero, () => _focusNode.requestFocus());
  }

  // New evaluation function: We first check for top‑level + and – (including the en dash “–”)
  int _evaluateExpression(String expression) {
    try {
      expression = expression.trim();
      // Handle addition
      if (expression.contains("+")) {
        var parts = expression.split("+");
        int sum = 0;
        for (var part in parts) {
          sum += _evaluateExpression(part.trim());
        }
        return sum;
      }
      // Handle en dash subtraction
      if (expression.contains("–")) {
        var parts = expression.split("–");
        int left = _evaluateExpression(parts[0].trim());
        int right = _evaluateExpression(parts[1].trim());
        return left - right;
      }
      // Handle subtraction with "-" (if not a negative number)
      if (expression.contains("-") && !expression.startsWith("-")) {
        var parts = expression.split("-");
        int result = _evaluateExpression(parts[0].trim());
        for (int i = 1; i < parts.length; i++) {
          result -= _evaluateExpression(parts[i].trim());
        }
        return result;
      }
      if (expression.contains("*")) {
        var parts = expression.split("*");
        int product = 1;
        for (var part in parts) {
          product *= _evaluateExpression(part.trim());
        }
        return product;
      }
      if (expression.contains("÷")) {
        var parts = expression.split("÷");
        int result = _evaluateExpression(parts[0].trim());
        for (int i = 1; i < parts.length; i++) {
          result = result ~/ _evaluateExpression(parts[i].trim());
        }
        return result;
      }
      // Handle square roots (assumes expression starts with "√")
      if (expression.startsWith("√")) {
        String baseStr = expression.substring(1).trim();
        int base = int.parse(baseStr);
        return sqrt(base).toInt();
      }
      // Handle cubic roots (assumes expression starts with "∛")
      if (expression.startsWith("∛")) {
        String baseStr = expression.substring(1).trim();
        int base = int.parse(baseStr);
        return pow(base, 1/3).round();
      }
      // Handle squares
      if (expression.contains("²")) {
        int base = int.parse(expression.replaceAll("²", "").trim());
        return pow(base, 2).toInt();
      }
      // Handle cubes
      if (expression.contains("³")) {
        int base = int.parse(expression.replaceAll("³", "").trim());
        return pow(base, 3).toInt();
      }
      // If plain number:
      return int.tryParse(expression) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  void _validateAnswer() {
    final correctAnswer = _evaluateExpression(currentExpression);
    double userAnswer = double.tryParse(userInput.replaceAll(",", ".")) ?? double.nan;
    if (mounted) {
      setState(() {
        totalQuestionsAnswered++;
        if ((userAnswer - correctAnswer).abs() < 0.01) {
          sessionScore++;
          if (sessionScore > highestScore) {
            highestScore = sessionScore;
          }
          if (totalQuestionsAnswered == 16) {
            _endGame();
          } else {
            _generateExpression();
          }
        } else {
          showingAnswer = true;
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

  void _endGame() {
    _stopwatch.stop();
    final elapsedTime = _stopwatch.elapsed;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xffffee9ae),
        title: Text(
          tr('game_screen.mission_over'),
          style: const TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "${tr('game_screen.correct_answers')} $sessionScore\n\n"
          "${tr('game_screen.time_taken')}: ${elapsedTime.inMinutes}m ${elapsedTime.inSeconds % 60}s\n\n"
          "${tr('game_screen.question')}",
          style: const TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Lottie.asset(
                        '/animations/lacis3.json',
                        height: 150,
                        width: 150,
                      ),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveHighestScore(widget.missionIndex, highestScore);
              Provider.of<MissionsProviderCalm>(context, listen: false)
                  .updateMissionProgress("Exponentiation", widget.missionIndex + 1, highestScore);
              await Future.delayed(const Duration(milliseconds: 100));
              int nextMissionIndex = widget.missionIndex + 1;
              if (nextMissionIndex < CalmBearGameExponentiation.missionModes.length) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalmBearGameExponentiation(
                      mode: CalmBearGameExponentiation.missionModes[nextMissionIndex],
                      missionIndex: nextMissionIndex,
                    ),
                  ),
                  (Route<dynamic> route) => route.isFirst,
                );
              } else {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: Text(
              tr('game_screen.next_mission'),
              style: const TextStyle(
                fontFamily: 'Mali',
                color: Color.fromARGB(255, 50, 50, 50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _saveHighestScore(widget.missionIndex, highestScore);
              Provider.of<MissionsProviderCalm>(context, listen: false)
                  .updateMissionProgress("Exponentiation", widget.missionIndex + 1, highestScore);
              await Future.delayed(const Duration(milliseconds: 100));
              Navigator.pop(context);
              Navigator.pop(context, highestScore);
            },
            child: Text(
              tr('game_screen.back_to_missions'),
              style: const TextStyle(
                fontFamily: 'Mali',
                color: Color.fromARGB(255, 50, 50, 50),
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
    // Evaluate the current expression and format the result
    final evaluatedResult = _evaluateExpression(currentExpression);
    final resultText = (evaluatedResult % 1 == 0)
        ? evaluatedResult.toInt().toString()
        : evaluatedResult.toStringAsFixed(2);
    // Determine if the answer is wrong
    final bool isWrong = showingAnswer && userInput.trim() != resultText;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _saveHighestScore(widget.missionIndex, highestScore);
            Provider.of<MissionsProviderCalm>(context, listen: false)
                .updateMissionProgress("Exponentiation", widget.missionIndex + 1, highestScore);
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
                  fontFamily: 'Mali',
                  color: Color.fromARGB(255, 50, 50, 50),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
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
                      "$totalQuestionsAnswered ${tr("game_screen.of_15")}",
                      style: const TextStyle(
                        fontFamily: 'Mali',
                        color: Color.fromARGB(255, 50, 50, 50),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    showingAnswer
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'Mali',
                                    fontSize: 38,
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
                              fontFamily: 'Mali',
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
                    fontFamily: 'Mali',
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