import 'package:flutter/material.dart';

class LearnView extends StatelessWidget {
  const LearnView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamically set the number of columns based on screen width
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    // List of card data for the grid
    final List<Map<String, String>> topics = [
      {'title': '1 + 1', 'subtitle': 'Addition'},
      {'title': '1 - 1', 'subtitle': 'Subtraction'},
      {'title': '1 × 1', 'subtitle': 'Multiplication'},
      {'title': '1 / 1', 'subtitle': 'Division'},
      {'title': '(4 + 1) - 4', 'subtitle': 'Mixed'},
      {'title': '4; 5; 9; 14; ...', 'subtitle': 'Sequences'},
      {'title': '(2)2', 'subtitle': 'Squares'},
      {'title': '%', 'subtitle': 'Percentages'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Learn',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.account_circle,
              size: 32,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: screenWidth > 600 ? 2 : 1.5,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.grey[300],
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    topics[index]['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (topics[index]['subtitle']!.isNotEmpty)
                    Text(
                      topics[index]['subtitle']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}