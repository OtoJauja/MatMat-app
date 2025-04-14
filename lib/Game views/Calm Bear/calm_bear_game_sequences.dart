// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Services/mission_provider_calm.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalmBearGameSequences extends StatefulWidget {
  final String mode;
  final int missionIndex;

  const CalmBearGameSequences({
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
    "sequence_fibonacci", // mission 7 will display 6 numbers with last one as x
    "sequence_x2_plus_1",
    "sequence_double_and_sum_digits",
    "sequence_primes",
  ];

  @override
  State<CalmBearGameSequences> createState() => _CalmBeeGameState();
}

class _CalmBeeGameState extends State<CalmBearGameSequences> {
  int sessionScore = 0; // The score for the current session
  int highestScore = 0; // The highest score loaded from storage
  int correctAnswers = 0;
  int totalQuestionsAnswered = 1;
  String currentSequence = "";
  String userInput = "";
  List<String> mistakes = [];
  bool gameStarted = false;
  bool showingAnswer = false;
  int nextValue = 0;
  late TextEditingController _controller;
  int preStartTimer = 5;
  late Stopwatch _stopwatch;
  late FocusNode _focusNode;

  Future<void> _saveHighestScore(int missionIndex, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    // Use a subject-specific key:
    String key = "Sequences_highestScore_$missionIndex";
    int storedScore = prefs.getInt(key) ?? 0;

    if (newScore > storedScore) {
      await prefs.setInt(key, newScore);
    }
  }

  Future<int> _loadHighestScore(int missionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "Sequences_highestScore_$missionIndex";
    return prefs.getInt(key) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();

    // Load the highest score for this mission at the start.
    _loadHighestScore(widget.missionIndex).then((value) {
      if (mounted) {
        setState(() {
          highestScore = value;
          sessionScore = 0; // Always start a new session with 0.
        });
      }
    });

    _startPreGameTimer();
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the FocusNode
    _controller.dispose();
    super.dispose();
  }

  // Timer for 5-second pre game countdown
  void _startPreGameTimer() {
    setState(() {
      sessionScore = 0; // Reset only the session score.
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
            _generateSequence();
          }
        });
      }
    });
  }

  void _generateSequence() {
    final random = Random();
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
        // Ensure no zeros
        increment = random.nextInt(90) + 10; // 10 to 99
        int minStart =
            5 * increment + 100; // Ensure the 6th number is at least 100.
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
    // For most modes, display 5 items
    // first three numbers then x then the fifth number
    // For Fibonacci mode display 6 items first five numbers then x
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
        showingAnswer = false;
      });
    }
    Future.delayed(Duration.zero, () => _focusNode.requestFocus());
  }

  bool _isPrime(int number) {
    if (number < 2) return false;
    for (int i = 2; i <= sqrt(number).toInt(); i++) {
      if (number % i == 0) return false;
    }
    return true;
  }

  void _validateAnswer() {
    final userAnswer = int.tryParse(userInput) ?? -1;
    if (mounted) {
      setState(() {
        totalQuestionsAnswered++; // Increment total questions
        if (userAnswer == nextValue) {
          sessionScore++; // Increment session score
          // Update highestScore if needed.
          if (sessionScore > highestScore) {
            highestScore = sessionScore;
          }
          if (totalQuestionsAnswered == 16) {
            _endGame();
          } else {
            _generateSequence();
          }
        } else {
          showingAnswer = true; // Show correct answer for incorrect response
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                showingAnswer = false;
                if (totalQuestionsAnswered < 16) {
                  _generateSequence();
                } else {
                  _endGame();
                }
              });
            }
          });
        }
      });
    }
  }

  // End the game
  void _endGame() {
    _stopwatch.stop();
    final elapsedTime = _stopwatch.elapsed;

    final FocusNode button1FocusNode = FocusNode();
    final FocusNode button2FocusNode = FocusNode();

    void nextMissionAction() async {
      // Save the highest score for the finished mission
      await _saveHighestScore(widget.missionIndex, highestScore);
      // Ensure the userId is passed to update the Firestore
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<MissionsProviderCalm>(context, listen: false)
            .updateMissionProgress(
                "Sequences", widget.missionIndex + 1, highestScore,
                userId: userId);
      }
      // Optionally wait a tiny bit to ensure the provider updates
      await Future.delayed(const Duration(milliseconds: 100));
      int nextMissionIndex = widget.missionIndex + 1;
      if (nextMissionIndex < CalmBearGameSequences.missionModes.length) {
        // Remove all game screens and push the next mission
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CalmBearGameSequences(
              mode: CalmBearGameSequences.missionModes[nextMissionIndex],
              missionIndex: nextMissionIndex,
            ),
          ),
          (Route<dynamic> route) => route.isFirst,
        );
      } else {
        // If no further missions are available, return to the mission view
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }

    void backToMissionsAction() async {
      await _saveHighestScore(widget.missionIndex, highestScore);
      // Update the provider
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<MissionsProviderCalm>(context, listen: false)
            .updateMissionProgress(
                "Sequences", widget.missionIndex + 1, highestScore,
                userId: userId);
      }
      await Future.delayed(const Duration(milliseconds: 100));
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
              if (event.logicalKey == LogicalKeyboardKey.digit1 || event.logicalKey == LogicalKeyboardKey.numpad1) {
                button1FocusNode.requestFocus();
              } else if (event.logicalKey == LogicalKeyboardKey.digit2 || event.logicalKey == LogicalKeyboardKey.numpad2) {
                button2FocusNode.requestFocus();
              } else if (event.logicalKey == LogicalKeyboardKey.enter ||
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
              tr('game_screen.mission_over'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "${tr('game_screen.correct_answers')} $sessionScore\n\n"
              "${tr('game_screen.time_taken')}: ${elapsedTime.inMinutes}m ${elapsedTime.inSeconds % 60}s\n\n"
              "${tr('game_screen.question')}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Lottie.asset(
              'assets/animations/lacis3.json',
              height: 150,
              width: 150,
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _saveHighestScore(widget.missionIndex, highestScore);
            Provider.of<MissionsProviderCalm>(context, listen: false)
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
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: gameStarted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$totalQuestionsAnswered${tr("game_screen.of_15")}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    showingAnswer
                        ? Column(mainAxisSize: MainAxisSize.min, children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontFamily: 'Mali',
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "x = ",
                                    style: TextStyle(
                                      color: Color(0xffffa400),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "$nextValue ",
                                    style: const TextStyle(
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                  // Display the users incorrect answer in red with a strike
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
                            const SizedBox(height: 20),// Plays animation if the answer is incorrect
                                Lottie.asset(
                                  'assets/animations/lacis5.json',
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.fill,
                                ),
                            ],
                          )
                        : Text(
                            currentSequence,
                            style: const TextStyle(
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
