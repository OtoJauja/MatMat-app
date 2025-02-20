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
          {
            'name': 'Multiplication from 1 to 20',
            'url': 'https://cf.ltkcdn.net/home-school/files/4425-times-tables-1-to-20.pdf'
          },
        ],
      },
      {
        'title': 'x ÷ y',
        'subtitle': 'Division',
        'tips': [
          {
            'name': 'Division Basics',
            'url': 'https://www.youtube.com/watch?v=rGMecZ_aERo'
          },
          {
            'name': 'Division from 1 to 10',
            'url': 'https://suncatcherstudio.com/uploads/printables/math/division-charts/pdf-png/printable-division-chart-filled-in-1-10-portrait-2288ee-44aaff.pdf'
          },
        ],
      },
      {
        'title': '4; 5; 9; 14; ...',
        'subtitle': 'Sequences',
        'tips': [
          {
            'name': 'Understanding Sequences',
            'url': 'https://www.youtube.com/watch?v=tfU1tNf_65s'
          },
          {
            'name': 'Understanding Sequences: nth Term',
            'url': 'https://www.youtube.com/watch?v=xtvJwaYfXss&t=1s'
          },
        ],
      },
      {
        'title': 'x²',
        'subtitle': 'Exponentiation',
        'tips': [
          {
            'name': 'Exponentiation Basics',
            'url': 'https://countontricia.com/2019/06/how-to-teach-exponents-to-beginners.html'
          },
          {
            'name': 'Introduction to Exponents',
            'url': 'https://www.youtube.com/watch?v=XZRQhkii0h0'
          },
          {
            'name': 'Square roots',
            'url': 'https://www.k8worksheets.com/pdfs/square-root/charts-4.pdf'
          },
          {
            'name': 'Cubic roots',
            'url': 'https://math-drills.com/numbersense/cubes_and_cube_roots_001.1360994964.pdf'
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
          {
            'name': 'Percentages in 10s',
            'url': 'https://www.smartboardingschool.com/_files/ugd/e99b9e_3d29122850c042189b087d1ca64e8999.pdf?index=true'
          },
          {
            'name': 'Percentages: Per 100',
            'url': 'https://www.mathsisfun.com/percentage.html'
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
                      .externalApplication, // LaunchMode .externalApplication or .inAppWebView
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
