import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectsAndMissions = {
      "Addition": [
        {"number": "1", "description": "Add 1-Digit Numbers"},
        {"number": "2", "description": "Add 1-Digit and 2-Digit Numbers"},
        {"number": "3", "description": "Add 2-Digit Numbers Without Carrying"},
        {"number": "4", "description": "Add 2-Digit Numbers With Carrying"},
        {"number": "5", "description": "Adding 3-Digit and 2-Digit Numbers"},
        {"number": "6", "description": "Add 3-Digit Numbers"},
        {"number": "7", "description": "Adding 4-Digit and 2-Digit Numbers"},
        {"number": "8", "description": "Adding 4-Digit and 3-Digit Numbers"},
        {"number": "9", "description": "Add 4-Digit Numbers"},
        {"number": "10", "description": "Addition of Decimals"},
      ],
      "Subtraction": [
        {"number": "1", "description": "Subtracting 2-Digit and 1-Digit Numbers"},
        {"number": "2", "description": "Subtracting 2-Digit Numbers"},
        {"number": "3", "description": "Subtracting 3-Digit by 2-Digit or 1-Digit Numbers Without Carrying"},
        {"number": "4", "description": "Subtracting 3-Digit by 2-Digit or 1-Digit Numbers With Carrying"},
        {"number": "5", "description": "Subtracting 3-Digit and 2-Digit and 1-Digit Numbers"},
        {"number": "6", "description": "Subtracting 3-Digit Numbers"},
        {"number": "7", "description": "Subtracting 4-Digit by 2-Digit Numbers"},
        {"number": "8", "description": "Subtracting 4-Digit by 3-Digit Numbers"},
        {"number": "9", "description": "Subtracting 4-Digit Numbers"},
        {"number": "10", "description": "Subtraction of Decimals"},
      ],
      "Multiplication": [
        {"number": "1", "description": "Multiplying 1-Digit Numbers"},
        {"number": "2", "description": "Multiplying  1-Digit x 2-Digit Numbers"},
        {"number": "3", "description": "Multiplying  2-Digit x 1-Digit Numbers"},
        {"number": "4", "description": "Multiplying  3-Digit x 1-Digit Numbers or vice versa"},
        {"number": "5", "description": "Multiplying 4-Digit x 1-Digit Numbers"},
        {"number": "6", "description": "Multiplying 2-Digit Numbers"},
        {"number": "7", "description": "Multiplying 1-Digit x 1-Digit x 1-Digit Numbers"},
        {"number": "8", "description": "Multiplying 2-Digit x 1-Digit x 1-Digit Numbers"},
        {"number": "9", "description": "Multiplying Decimal Numbers by 1-Digit Numbers"},
        {"number": "10", "description": "Multiplying Decimal Numbers"},
      ],
      "Division": [
        {"number": "1", "description": "Divide 1-Digit Numbers"},
        {"number": "2", "description": "Divide 1-Digit or 2-Digit Numbers by 1-Digit Numbers With a Decimal result"},
        {"number": "3", "description": "Divide 3-Digit by 1-Digit Numbers"},
        {"number": "4", "description": "Divide 4-Digit by 1-Digit Numbers"},
        {"number": "5", "description": "Divide 2-Digit Numbers"},
        {"number": "6", "description": "Divide 3-Digit by 2-Digit Numbers"},
        {"number": "7", "description": "Divide 3-Digit by 1-Digit by 1-Digit Numbers"},
        {"number": "8", "description": "Divide Decimals by 1-Digit Numbers"},
        {"number": "9", "description": "Divide 4-Digit Numbers by 1-Digit Numbers by 1-Digit Numbers"},
        {"number": "10", "description": "Divide Decimal Numbers by 2-Digit Numbers"},
      ],
      "Mixed operations": [
        {"number": "1", "description": "(1-Digit + 1-Digit) x 1-Digit Numbers"},
        {"number": "2", "description": "(1-Digit + 2-Digit) x 1-Digit Numbers"},
        {"number": "3", "description": "1-Digit x (2-Digit + 2-Digit) Numbers"},
        {"number": "4", "description": "(2-Digit + 1-Digit) x 1-Digit"},
        {"number": "5", "description": "(2-Digit - 1-Digit) x 1-Digit"},
        {"number": "6", "description": "2-Digit x 1-Digit - 1-Digit x 1-Digit Numbers"},
        {"number": "7", "description": "1-Digit x 2-Digit + 1-Digit x 2-Digit Numbers"},
        {"number": "8", "description": "3-Digit x 1-Digit - 1-Digit Numbers"},
        {"number": "9", "description": "(2-Digit + 2-Digit) ÷ 1-Digit Numbers"},
        {"number": "10", "description": "(3-Digit + 2-Digit) ÷ 1-Digit Numbers"},
      ],
      "Exponentiation": [
        {"number": "1", "description": "1-Digit Squared"},
        {"number": "2", "description": "2-Digit Squared"},
        {"number": "3", "description": "1-Digit Cubed"},
        {"number": "4", "description": "1-Digit Squared + 1-Digit Squared"},
        {"number": "5", "description": "1-Digit Cubed - 1-Digit Squared"},
        {"number": "6", "description": "Square root of 1-Digit, 2-Digit or 3-Digit Numbers"},
        {"number": "7", "description": "Cubic root of 1-Digit, 2-Digit or 3-Digit Numbers"},
        {"number": "8", "description": "Square root of 1-Digit or 2-Digit + 1-Digit Squared"},
        {"number": "9", "description": "Square root of 2-Digit × square root of 2-Digit Numbers"},
        {"number": "10", "description": "Square of 2-Digits Divided by the square root of 2-Digits or 3-Digits"},
      ],
      "Percentages": [
        {"number": "1", "description": "10% of 2-Digit or 3-Digit Numbers"},
        {"number": "2", "description": "20% of 2-Digit or 3-Digit Numbers"},
        {"number": "3", "description": "50% of 1-Digit, 2-Digit or 3-Digit Numbers"},
        {"number": "4", "description": "20%, 25% or 50% of 2-Digit or 3-Digit Numbers"},
        {"number": "5", "description": "Increase 2-Digit Numbers by 10%, 20%, 25% or 50%"},
        {"number": "6", "description": "Decreae 2-Digit Numbers by 10% or 50%"},
        {"number": "7", "description": "30% of 2-Digit Numbers"},
        {"number": "8", "description": "Increase 3-Digit Numbers by 10%, 20%, 25% or 50%"},
        {"number": "9", "description": "1-Digit % of 2-Digit Numbers"},
        {"number": "10", "description": "2-Digit % of 2-Digit numbers"},
      ],
      "Sequences": [
        {"number": "1", "description": "Start with 1; 2; 3 or 4 and add 1-Digit. For example, 4; 11; 18; 25; ..."},
        {"number": "2", "description": "Start with 2-Digit numbers and add 1-Digit numbers. For example, 23; 28; 33; 38; ..."},
        {"number": "3", "description": "Start with 3-Digit Numbers and subtract 1-Digit or 2 Digit numbers. For example, 345; 340; 335; 330; ..."},
        {"number": "4", "description": "Start with a 1-Digit number and multiply by 2 or 3. For example, 3; 6; 12; 24; ..."},
        {"number": "5", "description": "Start with a 2-Digit number and multiply by 2 or 3. For example, 21; 63; 189; 56; ..."},
        {"number": "6", "description": "1-Digit or 2-Digit (<=20) squared. For example, 9; 16; 25; 36; ..."},
        {"number": "7", "description": "Fibonacci series starting with a 1-Digit number (>1). For example, 4; 5; 9; 14; ..."},
        {"number": "8", "description": "Starts with a 1-Digit number (>1) x 2 +1. For example, 4; 9; 19; 39; ..."},
        {"number": "9", "description": "Double a 1-Digit number and the next number is the sum of the digits. For example, 66; 12; 77; 14; ..."},
        {"number": "10", "description": "Start with a 1-Digit or 2-Digit prime number. For example, 11; 13; 17; 19; ..."},
      ],
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),  
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.account_circle,
              size: 32,
              color: Color.fromARGB(255, 50, 50, 50),  
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: subjectsAndMissions.keys.map((subject) {
            return Card(
              color: const Color(0xffffee9ae),
              child: ExpansionTile(
                title: Text(
                  subject,
                  style: const TextStyle(fontFamily: 'Mali',
                    color: Color.fromARGB(255, 50, 50, 50),  
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                      ),
                  ),
                children: subjectsAndMissions[subject]!.map<Widget>((mission) {
                  return ListTile(
                    title: Text(
                      '${mission["number"]}. ${mission["description"]}',
                      style: const TextStyle(fontFamily: 'Mali',
                    color: Color.fromARGB(255, 50, 50, 50),  
                    fontSize: 16,
                      ),
                  ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}