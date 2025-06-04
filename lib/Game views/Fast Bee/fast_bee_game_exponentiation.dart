import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Services/mission_provider_fast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastBeeGameExponentiation extends StatefulWidget {
  // The expressions should work correctly
  final String mode;
  final int missionIndex;

  const FastBeeGameExponentiation({
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
  State<FastBeeGameExponentiation> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameExponentiation>
    with SingleTickerProviderStateMixin {
  int sessionScore = 0; // The score for the current session
  int highestScore = 0; // The highest score loaded from storage
  late Timer _timer; // Countdown timer for the game
  late int timeLeft; // Time left for the game
  int preStartTimer = 5; // Countdown before the game starts
  int correctAnswers = 0; // Track correct answers
  int totalQuestionsAnswered = 0; // Track total questions answered
  String currentExpression = ""; // Current math expression
  String userInput = ""; // User's input
  bool gameStarted = false; // Flag to indicate game has started
  bool canSkip = false;
  late TextEditingController _controller; // Persistent controller
  late FocusNode _focusNode; // Focus to auto-click input
  late AnimationController _lottieController;
  late FocusNode _keyboardFocusNode; // Skip button click

  // Timer for the skip functionality
  Timer? _skipTimer;

  // Input field fill color variable
  Color _inputFillColor = const Color(0xffffee9ae);

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastExponentiation_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastExponentiation_highestScore_$missionIndex";
    return prefs.getInt(key) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    timeLeft = widget.missionIndex >= 5
        ? 120
        : 90; // Adjust time based on mission - 1-5 = 60s / 6-10 = 120
    _focusNode = FocusNode();
    _keyboardFocusNode = FocusNode();
    _controller = TextEditingController();
    _lottieController = AnimationController(vsync: this);
    // Load the highest score for this mission at the start
    _loadHighestScore(widget.missionIndex).then((value) {
      if (mounted) {
        setState(() {
          highestScore = value;
          sessionScore = 0; // Always start a new session with 0
        });
      }
    });
    _startPreGameTimer();
  }

  @override
  void dispose() {
    _lottieController.dispose(); // Dispose the controller
    _skipTimer?.cancel(); // Cancel the skip timer if it's active
    _focusNode.dispose(); // Dispose of the FocusNode
    _controller.dispose();
    _keyboardFocusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Timer for 5-second pre-game countdown
  void _startPreGameTimer() {
    setState(() {
      sessionScore = 0; // Reset only the session score
      totalQuestionsAnswered = 1;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
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
      if (mounted) {
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
    _skipTimer?.cancel();
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
        // Ensure the first number is larger than the second.
        if (a <= b) {
          int temp = a;
          a = b;
          b = temp;
          if (a == b) {
            // Adjust if they end up equal.
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
        // Exclude 1³ by starting at 2³.
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
        int a =
            perfectSquares2Digit[random.nextInt(perfectSquares2Digit.length)];
        int b =
            perfectSquares2Digit[random.nextInt(perfectSquares2Digit.length)];
        currentExpression = "√$a * √$b";
        break;
      case "square_of_2_digit_divided_square_root_of_2_digit_or_3_digit":
        List<int> twoDigitSquares = [16, 25, 36, 49, 64, 81];
        List<int> threeDigitSquares = [
          100,
          121,
          144,
          169,
          196,
          225,
          256,
          289,
          324,
          361,
          400,
          441,
          484,
          529,
          576,
          625,
          676,
          729,
          784,
          841,
          900,
          961
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
        canSkip = false;
        // Reset the fill color back to default
        _inputFillColor = const Color(0xffffee9ae);
        _focusNode.requestFocus();
      });
    }

    // Start a new timer to enable skip after 5 seconds
    _skipTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          canSkip = true;
        });
      }
    });
  }

  // Evaluate a math expression
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
        return pow(base, 1 / 3).round();
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

  // Validate user's answer
  void _validateAnswer() {
    final correctAnswer = _evaluateExpression(currentExpression);
    double userAnswer =
        double.tryParse(userInput.replaceAll(",", ".")) ?? double.nan;
    if (mounted) {
      // If the answer is correct
      if ((userAnswer - correctAnswer).abs() < 0.01) {
        setState(() {
          sessionScore++; // Increment the session score
          // Update highestScore if needed.
          if (sessionScore > highestScore) {
            highestScore = sessionScore;
          }
          // Change input field color to green as a confirmation
          _inputFillColor = Colors.green.shade200;
        });
        // Wait for 1 second before proceeding to the next expression
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              totalQuestionsAnswered++;
              _generateExpression();
              _inputFillColor = const Color(0xffffee9ae);
            });
          }
        });
      }
    }
  }

  // Skip the current question
  void _skipQuestion() {
    if (canSkip) {
      // Cancel the current skip timer so it doesn't override new state
      _skipTimer?.cancel();
      if (mounted) {
        setState(() {
          _generateExpression();
          canSkip = false;
        });
      }
    }
  }

  // End the game
  void _endGame() {
    final FocusNode button1FocusNode = FocusNode();
    final FocusNode button2FocusNode = FocusNode();

    void nextMissionAction() async {
      // Save the highest score for the finished mission
      await _saveHighestScore(widget.missionIndex, highestScore);

      // Ensure the userId is passed to update the Firestore
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        if(!mounted) return;
        Provider.of<MissionsProviderFast>(context, listen: false)
            .updateMissionProgress(
                "Exponentiation", widget.missionIndex + 1, highestScore,
                userId: userId);
      }

      await Future.delayed(const Duration(milliseconds: 100));

      int nextMissionIndex = widget.missionIndex + 1;
      if (nextMissionIndex < FastBeeGameExponentiation.missionModes.length) {
        if(!mounted) return;
        // Remove all game screens and push the next mission
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => FastBeeGameExponentiation(
              mode: FastBeeGameExponentiation.missionModes[nextMissionIndex],
              missionIndex: nextMissionIndex,
            ),
          ),
          (Route<dynamic> route) => route.isFirst,
        );
      } else {
        if(!mounted) return;
        // If no further missions are available, return to the mission view
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }

    void backToMissionsAction() async {
      await _saveHighestScore(widget.missionIndex, highestScore);
      // Update the provider
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        if(!mounted) return;
        Provider.of<MissionsProviderFast>(context, listen: false)
            .updateMissionProgress(
                "Exponentiation", widget.missionIndex + 1, highestScore,
                userId: userId);
      }
      await Future.delayed(const Duration(milliseconds: 100));
      if(!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context, highestScore);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final FocusNode rawKeyboardFocusNode = FocusNode();

        return KeyboardListener(
          focusNode: rawKeyboardFocusNode,
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              // When 1 is pressed, request focus for button 1
              if (event.logicalKey == LogicalKeyboardKey.digit1 || event.logicalKey == LogicalKeyboardKey.numpad1) {
                button1FocusNode.requestFocus();
              }
              // When 2 is pressed, request focus for button 2
              else if (event.logicalKey == LogicalKeyboardKey.digit2 || event.logicalKey == LogicalKeyboardKey.numpad2) {
                button2FocusNode.requestFocus();
              }
              // When Enter is pressed, activate the focused button
              else if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                if (button1FocusNode.hasFocus) {
                  nextMissionAction();
                } else if (button2FocusNode.hasFocus) {
                  backToMissionsAction();
                }
              }
            }
          },
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              tr('game_screen.times_up'),
              style: const TextStyle(
                color: Color.fromARGB(255, 50, 50, 50),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "${tr('game_screen.correct_answers')} $sessionScore\n\n${tr('game_screen.question')}",
              style: const TextStyle(
                color: Color.fromARGB(255, 50, 50, 50),
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Lottie.asset(
              'assets/animations/B3.json',
              height: 170,
              width: 170,
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
                _lottieController.forward(); // Plays the animation once
              },
              repeat: false, // Ensure the animation does not loop
            ),
            actions: [
              Focus(
                focusNode: button1FocusNode,
                child: Builder(
                  builder: (context) {
                    final bool hasFocus = Focus.of(context).hasFocus;
                    return TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return hasFocus ? const Color(0xffffa400) : null;
                          },
                        ),
                      ),
                      onPressed: nextMissionAction,
                      child: Text(
                        tr('game_screen.next_mission'),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 50, 50, 50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Focus(
                focusNode: button2FocusNode,
                child: Builder(
                  builder: (context) {
                    final bool hasFocus = Focus.of(context).hasFocus;
                    return TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return hasFocus ? const Color(0xffffa400) : null;
                          },
                        ),
                      ),
                      onPressed: backToMissionsAction,
                      child: Text(
                        tr('game_screen.back_to_missions'),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 50, 50, 50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,               // grab focus as soon as screen appears
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          // if ok / enter is presses skip is activated
          if ((event.logicalKey == LogicalKeyboardKey.enter) &&
              canSkip) {
            _skipQuestion();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    child:   Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _saveHighestScore(widget.missionIndex, highestScore);
            // Update the provider
            Provider.of<MissionsProviderFast>(context, listen: false)
                .updateMissionProgress(
                    "Exponentiation", widget.missionIndex + 1, highestScore);
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
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: gameStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "$timeLeft ${tr('game_screen.seconds')}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    currentExpression,
                    style: const TextStyle(
                      color: Color(0xffffa400),
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                      focusNode: _focusNode,
                      cursorColor: const Color(0xffffa400),
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                      onChanged: (value) {
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
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffffa400)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffffa400)),
                        ),
                        fillColor: _inputFillColor,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: canSkip ? _skipQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffffa400),
                    ),
                    child: Text(
                      tr('game_screen.skip'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                preStartTimer > 0
                    ? "$preStartTimer"
                    : tr('game_screen.get_ready'),
                style: const TextStyle(
                  color: Color(0xffffa400),
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
      ),
    ));
  }
}
