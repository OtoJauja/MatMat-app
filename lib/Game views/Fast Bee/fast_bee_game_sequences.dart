import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Services/mission_provider_fast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastBeeGameSequences extends StatefulWidget {
  // I think currently everything is fine
  final String mode;
  final int missionIndex;

  const FastBeeGameSequences({
    super.key,
    required this.mode,
    required this.missionIndex,
  });

  static const List<String> missionModes = [
    "sequence_start_add_1_digit",
    "sequence_2_digit_add_1_digit",
    "sequence_3_digit_subtract",
    "sequence_1_digit_multiply",
    "sequence_2_digit_multiply",
    "sequence_squares",
    "sequence_fibonacci",       // mission 7 will display 6 numbers with last one as x
    "sequence_x2_plus_1",
    "sequence_double_and_sum_digits",
    "sequence_primes",
  ];

  @override
  State<FastBeeGameSequences> createState() => _FastBeeGameState();
}

class _FastBeeGameState extends State<FastBeeGameSequences> {
  int sessionScore = 0; // The score for the current session
  int highestScore = 0; // The highest score loaded from storage
  late Timer _timer;
  int timeLeft = 90;
  int preStartTimer = 5;
  int correctAnswers = 0;
  int totalQuestionsAnswered = 1; // Track total questions answered
  String currentSequence = "";
  String userInput = "";
  List<String> mistakes = [];
  bool gameStarted = false;
  bool canSkip = false;
  int nextValue = 0;
  late TextEditingController _controller;
  late FocusNode _focusNode; // Focus to autoclick input

  // Timer for the skip functionality
  Timer? _skipTimer;

  // Input field fill color variable
  Color _inputFillColor = const Color(0xffffee9ae);

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastSequences_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "fastSequences_highestScore_$missionIndex";
    return prefs.getInt(key) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    timeLeft = widget.missionIndex >= 5 ? 120 : 90; // Adjust time based on mission - 1-5 = 60s / 6-10 = 120
    _focusNode = FocusNode();
    _controller = TextEditingController();
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
    _skipTimer?.cancel(); // Cancel the skip timer if it's active
    _focusNode.dispose(); // Dispose of the FocusNode
    _controller.dispose();
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
            _generateSequence();
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

  void _generateSequence() {
    final random = Random();
    _skipTimer?.cancel();
    List<int> sequence = [];
    int start;
    int increment;

    switch (widget.mode) {
      case "sequence_start_add_1_digit":
        start = random.nextInt(6) + 1; // 1 to 6
        increment = random.nextInt(9) + 1; // 1 to 9
        sequence = List.generate(6, (i) => start + i * increment);
        break;
      case "sequence_2_digit_add_1_digit":
        start = random.nextInt(90) + 10; // 10 to 99
        increment = random.nextInt(9) + 1;
        sequence = List.generate(6, (i) => start + i * increment);
        break;
      case "sequence_3_digit_subtract":
        // Ensure we do not get zeros.
        increment = random.nextInt(90) + 10; // 10 to 99
        int minStart = 5 * increment + 100; // Ensure the 6th number is at least 100.
        if (minStart > 999) {
          minStart = 999;
        }
        start = random.nextInt(999 - minStart + 1) + minStart;
        sequence = List.generate(6, (i) => start - i * increment);
        break;
      case "sequence_1_digit_multiply":
        start = random.nextInt(9) + 1;
        int multiplier = random.nextBool() ? 2 : 3;
        sequence = List.generate(6, (i) => start * pow(multiplier, i).toInt());
        break;
      case "sequence_2_digit_multiply":
        start = random.nextInt(90) + 10;
        int multiplier = random.nextBool() ? 2 : 3;
        sequence = List.generate(6, (i) => start * pow(multiplier, i).toInt());
        break;
      case "sequence_squares":
        start = random.nextInt(20) + 1;
        sequence = List.generate(6, (i) => pow(start + i, 2).toInt());
        break;
      case "sequence_fibonacci":
        int a = random.nextInt(9) + 2;
        int b = random.nextInt(9) + 2;
        sequence = [a, b];
        for (int i = 2; i < 6; i++) {
          sequence.add(sequence[i - 1] + sequence[i - 2]);
        }
        break;
      case "sequence_x2_plus_1":
        start = random.nextInt(9) + 2;
        sequence = List.generate(6, (i) {
          if (i == 0) return start;
          start = start * 2 + 1;
          return start;
        });
        break;
      case "sequence_double_and_sum_digits":
        start = random.nextInt(89) + 10;
        sequence = [start];
        for (int i = 1; i < 6; i++) {
          if (i % 2 == 1) {
            start = start
                .toString()
                .split('')
                .map(int.parse)
                .reduce((a, b) => a + b);
          } else {
            start = random.nextInt(89) + 10;
          }
          sequence.add(start);
        }
        break;
      case "sequence_primes":
        sequence = [];
        int candidate = random.nextInt(50) + 10;
        while (sequence.length < 6) {
          if (_isPrime(candidate)) {
            sequence.add(candidate);
          }
          candidate++;
        }
        break;
    }

    // Transform the generated full sequence into the display format
    // For most modes, we display 5 items
    // first three numbers, then x then the fifth number
    // For the Fibonacci mode display 6 items first five numbers then x
    if (widget.mode == "sequence_fibonacci") {
      nextValue = sequence[5];
      currentSequence =
          "${sequence[0]}; ${sequence[1]}; ${sequence[2]}; ${sequence[3]}; ${sequence[4]}; x";
    } else {
      // For all other modes display 5 items replacing the fourth number with x
      nextValue = sequence[3];
      currentSequence =
          "${sequence[0]}; ${sequence[1]}; ${sequence[2]}; x; ${sequence[4]}";
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

  bool _isPrime(int number) {
    if (number < 2) return false;
    for (int i = 2; i <= sqrt(number).toInt(); i++) {
      if (number % i == 0) return false;
    }
    return true;
  }

  // Validate user's answer
  void _validateAnswer() {
    if (int.tryParse(userInput) == nextValue) {
      if (mounted == true) {
        setState(() {
          sessionScore++;
          totalQuestionsAnswered++;
          if (sessionScore > highestScore) {
            highestScore = sessionScore;
          }
          _inputFillColor = Colors.green.shade200;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              totalQuestionsAnswered++;
              _generateSequence();
              _inputFillColor = const Color(0xffffee9ae);
            });
          }
        });
      }
    }
  }

  void _skipQuestion() {
    if (canSkip) {
      // Cancel the current skip timer so it doesn't override new state
      _skipTimer?.cancel();
      if (mounted) {
        setState(() {
          _generateSequence();
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
        actions: [
          TextButton(
            onPressed: () async {
              // Save the highest score for the finished mission
              await _saveHighestScore(widget.missionIndex, highestScore);

              // Update the provider for the finished mission
              Provider.of<MissionsProviderFast>(context, listen: false)
                  .updateMissionProgress(
                      "Sequences", widget.missionIndex + 1, highestScore);

              // Optionally wait a tiny bit to ensure the provider updates
              await Future.delayed(const Duration(milliseconds: 100));

              int nextMissionIndex = widget.missionIndex + 1;
              if (nextMissionIndex < FastBeeGameSequences.missionModes.length) {
                // Remove all game screens and push the next mission
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastBeeGameSequences(
                      mode: FastBeeGameSequences.missionModes[nextMissionIndex],
                      missionIndex: nextMissionIndex,
                    ),
                  ),
                  (Route<dynamic> route) => route.isFirst,
                );
              } else {
                // If no further missions are available, return to the mission view
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
              // Update the provider
              Provider.of<MissionsProviderFast>(context, listen: false)
                  .updateMissionProgress(
                      "Sequences", widget.missionIndex + 1, highestScore);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _saveHighestScore(widget.missionIndex, highestScore);
            // Update the provider
            Provider.of<MissionsProviderFast>(context, listen: false)
                .updateMissionProgress(
                    "Sequences", widget.missionIndex + 1, highestScore);
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
      backgroundColor: Colors.white,
      body: Center(
        child: gameStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "⏳ $timeLeft ${tr('game_screen.seconds')}",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 50, 50, 50),
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    currentSequence,
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
                      focusNode: _focusNode,
                      cursorColor: const Color(0xffffa400),
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      backgroundColor: const Color(0xffffee9ae),
                    ),
                    child: Text(
                      tr('game_screen.skip'),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 50, 50, 50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                preStartTimer > 0 ? "$preStartTimer" : tr('game_screen.get_ready'),
                style: const TextStyle(
                  color: const Color(0xffffa400),
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
      ),
    );
  }
}
