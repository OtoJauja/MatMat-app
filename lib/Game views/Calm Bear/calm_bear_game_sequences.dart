import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    "sequence_fibonacci",
    "sequence_x2_plus_1",
    "sequence_double_and_sum_digits",
    "sequence_primes",
  ];

  @override
  State<CalmBearGameSequences> createState() => _CalmBeeGameState();
}

class _CalmBeeGameState extends State<CalmBearGameSequences> {
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
    super.dispose();
  }

  void _startPreGameTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
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
    });
  }

  void _generateSequence() {
    final random = Random();
    List<int> sequence = [];
    int start;
    int increment;

    switch (widget.mode) {
      case "sequence_start_add_1_digit":
        start = random.nextInt(6) + 1;
        increment = random.nextInt(9) + 1;
        sequence = List.generate(6, (i) => start + i * increment);
        break;
      case "sequence_2_digit_add_1_digit":
        start = random.nextInt(90) + 10;
        increment = random.nextInt(9) + 1;
        sequence = List.generate(6, (i) => start + i * increment);
        break;
      case "sequence_3_digit_subtract":
        start = random.nextInt(900) + 100;
        increment = random.nextInt(90) + 10;
        sequence = [];
        for (int i = 0; i < 6; i++) {
          int value = start - i * increment;
          if (value < 0) {
            value = 0;
          }
          sequence.add(value);
        }
        break;
      case "sequence_1_digit_multiply":
        start = random.nextInt(9) + 1;
        increment = random.nextBool() ? 2 : 3;
        sequence = List.generate(6, (i) => start * pow(increment, i).toInt());
        break;
      case "sequence_2_digit_multiply":
        start = random.nextInt(90) + 10;
        increment = random.nextBool() ? 2 : 3;
        sequence = List.generate(6, (i) => start * pow(increment, i).toInt());
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
        sequence = List.generate(6, (i) => (start = start * 2 + 1));
        break;
      case "sequence_double_and_sum_digits":
        start = random.nextInt(89) + 10;
        sequence.add(start);
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
        int primeCount = 0;
        int candidate = random.nextInt(50) + 10;
        while (primeCount < 6) {
          if (_isPrime(candidate)) {
            sequence.add(candidate);
            primeCount++;
          }
          candidate++;
        }
        break;
    }

    setState(() {
      currentSequence = sequence.take(5).join(", ");
      nextValue = sequence.length > 5
          ? sequence[5]
          : 0; // Safeguard for short sequences
      userInput = "";
      _controller.text = "";
      showingAnswer = false;
    });
    Future.delayed(Duration.zero,
        () => _focusNode.requestFocus()); // Delay to ensure UI updates
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
    setState(() {
      totalQuestionsAnswered++; // Increment the total questions counter

      if (userAnswer == nextValue) {
        correctAnswers++; // Increment correct answers if the user's input is correct
        if (correctAnswers == 16) {
          _endGame(); // End the game if the user reaches 15 correct answers
        } else {
          _generateSequence(); // Generate the next sequence for the next question
        }
      } else {
        showingAnswer = true; // Set flag to show the correct answer
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            showingAnswer = false;
            if (totalQuestionsAnswered < 16) {
              _generateSequence();
              _focusNode
                  .requestFocus(); // Ensure focus returns after showing the answer
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
            if (nextMissionIndex < CalmBearGameSequences.missionModes.length) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CalmBearGameSequences(
                    mode: CalmBearGameSequences.missionModes[nextMissionIndex],
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
            Navigator.pop(context, correctAnswers); // Pass the correct answers back to the previous screen

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
                            "Correct Answer: $nextValue",
                            style: GoogleFonts.mali(
                              color: const Color(0xffffa400),
                              fontWeight: FontWeight.bold,
                              fontSize: 48,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            currentSequence,
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
