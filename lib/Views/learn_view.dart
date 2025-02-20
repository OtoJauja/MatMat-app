import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnView extends StatelessWidget {
  const LearnView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    final List<Map<String, dynamic>> topics = [
      {
        'title': 'x × y',
        'subtitle': 'Multiplication',
        'tips': [
          {
            'name': 'Fun Multiplication tricks',
            'url': 'https://www.boredteachers.com/post/multiplication-tricks'
          },
          {
            'name': 'Fun Multiplication video',
            'url': 'https://www.youtube.com/watch?v=eW2dRLyoyds&t=159s'
          },
        ],
      },
      {
        'title': 'x ÷ y',
        'subtitle': 'Division',
        'tips': [
          {
            'name': 'Division Tips',
            'url': 'https://www.idtech.com/blog/easy-division-tricks-for-kids'
          },
        ],
      },
      {
        'title': '4; 5; 9; 14; ...',
        'subtitle': 'Sequences',
        'tips': [
          {
            'name': 'Understanding Sequences',
            'url': 'https://www.example.com/sequences'
          },
        ],
      },
      {
        'title': 'x²',
        'subtitle': 'Exponentiation',
        'tips': [
          {
            'name': 'Exponentiation Basics',
            'url': 'https://www.example.com/exponentiation'
          },
        ],
      },
      {
        'title': '%',
        'subtitle': 'Percentages',
        'tips': [
          {
            'name': 'Percentages Made Simple',
            'url': 'https://byjus.com/maths/percentage/'
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
              color: Color.fromARGB(255, 50, 50, 50),
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
            final topic = topics[index];
            return InkWell(
              onTap: () {
                // Navigate to TipsView, passing the current topic's details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TipsView(
                      topicTitle: topic['title'],
                      topicSubtitle: topic['subtitle'],
                      tips: topic['tips'],
                    ),
                  ),
                );
              },
              child: Card(
                color: const Color(0xffffee9ae),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      topic['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (topic['subtitle'] != null &&
                        topic['subtitle'].toString().isNotEmpty)
                      Text(
                        topic['subtitle'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 50, 50, 50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TipsView extends StatelessWidget {
  final String topicTitle;
  final String topicSubtitle;
  final List<dynamic> tips;

  const TipsView({
    Key? key,
    required this.topicTitle,
    required this.topicSubtitle,
    required this.tips,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          topicTitle,
          style: const TextStyle(
            color: Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: tips.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final tip = tips[index];
          return ListTile(
            title: Text(
              tip['name'],
              style: const TextStyle(
                color: Color.fromARGB(255, 50, 50, 50),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final url = Uri.parse(tip['url']);
              if (await canLaunchUrl(url)) {
                await launchUrl(
                  url,
                  mode: LaunchMode
                      .inAppWebView, // or LaunchMode.externalApplication
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not open the link ${tip['url']}'),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
